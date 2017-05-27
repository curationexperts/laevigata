require 'rails_helper'
require 'workflow_setup'
require 'active_fedora/cleaner'

RSpec.describe WorkflowSetup do
  let(:w) { described_class.new }
  let(:superuser_email) { "superuser@emory.edu" }
  let(:admin_set_title) { "School of Hard Knocks" }
  it "can instantiate" do
    expect(w).to be_instance_of(described_class)
  end
  it "makes an admin Role" do
    admin = w.admin_role
    expect(admin).to be_instance_of(Role)
    expect(Role.where(name: "admin").count).to eq 1
  end
  it "makes a superuser" do
    w.make_superuser(superuser_email)
    expect(User.where(email: superuser_email).count).to eq 1
    expect((w.admin_role.users.map(&:email).include? superuser_email)).to eq true
  end
  it "returns all the superusers" do
    s = %w[admin1@example.com admin2@example.com admin3@example.com]
    s.each do |t|
      w.make_superuser(t)
    end
    expect(w.superusers.count).to eq 3
    expect(w.superusers.pluck(:email).include?(s.first)).to be true
  end
  it "throws an error if there are no superusers" do
    expect { w.superusers }.to raise_error(RuntimeError)
  end
  it "loads all the superusers from a file" do
    w.superusers_config = "#{fixture_path}/config/emory/superusers.yml"
    w.load_superusers
    expect((w.admin_role.users.map(&:email).include? "bnash@emory.edu")).to eq true
  end
  it "makes an AdminSet" do
    ActiveFedora::Cleaner.clean!
    w.load_superusers
    expect(w.make_admin_set(admin_set_title)).to be_instance_of AdminSet
    expect(AdminSet.where(title: admin_set_title).count).to eq 1
  end
  it "won't make a second admin set with the same title, it will just return the one that exists already" do
    ActiveFedora::Cleaner.clean!
    w.load_superusers
    a = w.make_admin_set(admin_set_title)
    expect(a).to be_instance_of AdminSet
    expect(AdminSet.where(title: admin_set_title).count).to eq 1
    b = w.make_admin_set(admin_set_title)
    expect(b).to be_instance_of AdminSet
    expect(AdminSet.where(title: admin_set_title).count).to eq 1
  end
  it "throws an error if it tries to load workflow without an admin set" do
    expect { w.load_workflows }.to raise_error(RuntimeError)
  end
  it "loads and activates the workflows" do
    ActiveFedora::Cleaner.clean!
    w.load_superusers
    a = w.make_admin_set(admin_set_title)
    expect(AdminSet.where(title: admin_set_title).count).to eq 1
    expect(a.permission_template.available_workflows.where(name: "one_step_mediated_deposit").count).to eq 1
    w.activate_mediated_deposit(a)
    expect(a.active_workflow.name).to eq "one_step_mediated_deposit"
  end
  it "makes a mediated deposit admin set" do
    new_title = "A Different Title"
    w.make_superuser(superuser_email)
    admin_set = w.make_mediated_deposit_admin_set(new_title)
    expect(admin_set).to be_instance_of AdminSet
    expect(AdminSet.where(title: new_title).count).to eq 1
    expect(admin_set.active_workflow.name).to eq "one_step_mediated_deposit"
  end
  it "makes a mediated deposit admin set and enrolls participants" do
    skip "Save this for later... Jeremy has given us some clues but we aren't there yet"
    title = "With participants"
    w.make_mediated_deposit_admin_set(title)
    expect(AdminSet.where(title: title).count).to eq 1
    a = AdminSet.where(title: title).first
    expect(a.active_workflow.name).to eq "one_step_mediated_deposit"
    expect(w.depositing_role).to be_instance_of(Sipity::Role)
    expect(w.approving_role).to be_instance_of(Sipity::Role)
  end

  context "schools config" do
    it "has an array of all the schools" do
      expect(w.schools.include?("Laney Graduate School")).to eq true
      expect(w.schools.count).to eq 4
    end
    it "has config files for each school" do
      expect(w.school_config(w.schools.first)).to be_instance_of Hash
    end
    it "raises an error if it can't find an expected config file" do
      expect { w.school_config("foobar") }.to raise_error(RuntimeError, /Couldn't find expected config/)
    end
    context "school specific configs" do
      it "loads approvers from a file" do
        ActiveFedora::Cleaner.clean!
        w.config_file_dir = "#{fixture_path}/config/emory/"
        w.load_superusers
        admin_set = w.make_admin_set_from_config("Fake School")
        workflow = admin_set.permission_template.available_workflows.where(active: true).first
        expect(workflow.name).to eq "one_step_mediated_deposit"
        approving_role = Sipity::Role.where(name: "approving").first
        wf_role = Sipity::WorkflowRole.find_by(workflow: workflow, role_id: approving_role)
        approving_agents = wf_role.workflow_responsibilities.pluck(:agent_id)
        expect(approving_agents.count).to eq 5 # 1 uberadmin + 4 approvers from the file
      end
    end
  end
  context "already existing participants" do
    it "knows what users are enrolled in a given role for a given admin_set" do
      ActiveFedora::Cleaner.clean!
      w.load_superusers
      admin_set = w.make_mediated_deposit_admin_set("Yellow Submarine")
      yellow_submarine_approvers = w.users_in_role(admin_set, "approving")
      expect(yellow_submarine_approvers.count).to eq 1
      expect(yellow_submarine_approvers).to be_instance_of Array
      expect(yellow_submarine_approvers.first).to be_instance_of Sipity::Agent
    end
  end
  it "gives superusers superpowers" do
    ActiveFedora::Cleaner.clean!
    w.load_superusers
    expect(w.superusers.count).to be > 1 # This test won't be meaningful if there is only one superuser
    admin_set = w.make_mediated_deposit_admin_set("River School")
    workflow = admin_set.permission_template.available_workflows.where(active: true).first
    expect(workflow).to be_instance_of Sipity::Workflow
    approving_role = Sipity::Role.where(name: "approving").first
    wf_role = Sipity::WorkflowRole.find_by(workflow: workflow, role_id: approving_role)
    approving_agents = wf_role.workflow_responsibilities.pluck(:agent_id)
    expect(approving_agents.count).to eq 1 # The only approving user should be the one who created the admin set
    w.give_superusers_superpowers
    approving_agents = wf_role.workflow_responsibilities.pluck(:agent_id)
    expect(approving_agents.count).to eq w.superusers.count # Now all superusers have the approving role
  end
  it "allows any registered user to deposit anywhere" do
    ActiveFedora::Cleaner.clean!
    w.load_superusers
    admin_set = w.make_mediated_deposit_admin_set("Frog and Toad")
    workflow = admin_set.permission_template.available_workflows.where(active: true).first
    expect(workflow).to be_instance_of Sipity::Workflow
    depositing_role = Sipity::Role.where(name: "depositing").first
    wf_role = Sipity::WorkflowRole.find_by(workflow: workflow, role_id: depositing_role)
    depositing_agents = wf_role.workflow_responsibilities.pluck(:agent_id)
    expect(depositing_agents.count).to eq 1 # The only depositing user should be the one who created the admin set
    w.everyone_can_deposit_everywhere
    depositing_agents = wf_role.workflow_responsibilities.pluck(:agent_id)
    expect(depositing_agents.count).to eq 2 # Now there are 2 depositing_agents...
    # and the second depositing agent is a Group consisting of all registered users
    expect(Sipity::Agent.where(id: depositing_agents.last).first.proxy_for_id).to eq "registered"
    expect(Sipity::Agent.where(id: depositing_agents.last).first.proxy_for_type).to eq "Hyrax::Group"
  end
end
