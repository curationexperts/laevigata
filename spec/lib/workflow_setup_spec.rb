require 'rails_helper'
require 'workflow_setup'

RSpec.describe WorkflowSetup do
  let(:w) { described_class.new }
  let(:uberadmin_email) { "uberadmin@example.com" }
  let(:admin_set_title) { "School of Hard Knocks" }
  it "can instantiate" do
    expect(w).to be_instance_of(described_class)
  end
  it "makes an admin Role" do
    admin = w.admin_role
    expect(admin).to be_instance_of(Role)
    expect(Role.where(name: "admin").count).to eq 1
  end
  it "makes an uberadmin user" do
    w.make_uberadmin(uberadmin_email)
    expect(User.where(email: uberadmin_email).count).to eq 1
    expect((w.admin_role.users.map(&:email).include? uberadmin_email)).to eq true
  end
  it "returns the uberadmin user" do
    w.make_uberadmin(uberadmin_email)
    expect(w.uberadmin.email).to eq uberadmin_email
  end
  it "throws an error if uberadmin doesn't exist" do
    expect { w.uberadmin }.to raise_error(RuntimeError)
  end
  it "makes an AdminSet" do
    w.make_uberadmin(uberadmin_email)
    expect(w.make_admin_set(admin_set_title)).to be_instance_of AdminSet
    expect(AdminSet.where(title: admin_set_title).count).to eq 1
  end
  it "won't make a second admin set with the same title" do
    AdminSet.where(title: admin_set_title).each(&:destroy)
    w.make_uberadmin(uberadmin_email)
    w.make_admin_set(admin_set_title)
    expect(AdminSet.where(title: admin_set_title).count).to eq 1
    w.make_admin_set(admin_set_title)
    expect(AdminSet.where(title: admin_set_title).count).to eq 1
  end
  it "throws an error if it tries to load workflow without an admin set" do
    expect { w.load_workflows }.to raise_error(RuntimeError)
  end
  it "loads and activates the workflows" do
    AdminSet.where(title: admin_set_title).each(&:destroy)
    w.make_uberadmin(uberadmin_email)
    a = w.make_admin_set(admin_set_title)
    expect(AdminSet.where(title: admin_set_title).count).to eq 1
    expect(a.permission_template.available_workflows.where(name: "one_step_mediated_deposit").count).to eq 1
    w.activate_mediated_deposit(a)
    expect(a.active_workflow.name).to eq "one_step_mediated_deposit"
  end
  it "makes a mediated deposit admin set" do
    new_title = "A Different Title"
    w.make_mediated_deposit_admin_set(new_title)
    expect(AdminSet.where(title: new_title).count).to eq 1
    a = AdminSet.where(title: new_title).first
    expect(a.active_workflow.name).to eq "one_step_mediated_deposit"
  end
  it "makes a mediated deposit admin set and enrolls participants" do
    title = "With participants"
    w.make_mediated_deposit_admin_set(title)
    expect(AdminSet.where(title: title).count).to eq 1
    a = AdminSet.where(title: title).first
    expect(a.active_workflow.name).to eq "one_step_mediated_deposit"
    expect(w.depositing_role).to be_instance_of(Sipity::Role)
    expect(w.approving_role).to be_instance_of(Sipity::Role)
  end
end
