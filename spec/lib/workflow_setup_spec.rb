require 'rails_helper'
require 'workflow_setup'
require 'active_fedora/cleaner'
include Warden::Test::Helpers

RSpec.describe WorkflowSetup do
  before do
    ActiveFedora::Cleaner.clean!
    User.delete_all
  end
  # Change "/dev/null" to STDOUT to see all logging output
  let(:w) { described_class.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/admin_sets.yml", "/dev/null") }
  let(:superuser_uid) { "superuser001" }
  let(:admin_set_title) { "School of Hard Knocks" }
  it "can instantiate and make admin_set_owner" do
    expect(w).to be_instance_of(described_class)
    expect(User.where(uid: WorkflowSetup::ADMIN_SET_OWNER).count).to eq 1
  end
  it "makes a notification_owner" do
    w.make_notification_owner
    expect(User.where(uid: WorkflowSetup::NOTIFICATION_OWNER).count).to eq 1
  end
  it "makes an admin Role" do
    admin = w.admin_role
    expect(admin).to be_instance_of(Role)
    expect(Role.where(name: "admin").count).to eq 1
  end
  it "makes a superuser" do
    w.make_superuser(superuser_uid)
    expect(User.where(uid: superuser_uid).count).to eq 1
    expect((w.admin_role.users.map(&:uid).include? superuser_uid)).to eq true
  end
  it "ensures the superuser can make workflow roles" do
    w.make_superuser(superuser_uid)
    expect(w.superusers.first.can?(:manage, Sipity::WorkflowResponsibility)).to eq true
  end
  it "returns all the superusers" do
    s = %w[admin1 admin2 admin3]
    s.each do |t|
      w.make_superuser(t)
    end
    expect(w.superusers.count).to eq 4 # 3 + 1 existing admin_set_owner
    expect(w.superusers.pluck(:uid).include?(s.first)).to be true
  end
  it "loads all the superusers from a file" do
    w.load_superusers
    expect((w.admin_role.users.map(&:uid).include? "wonderwoman001")).to eq true
    expect(w.superusers.pluck(:uid).include?("wonderwoman001")).to eq true
  end
  it "makes an AdminSet" do
    w.load_superusers
    expect(w.make_admin_set(admin_set_title)).to be_instance_of AdminSet
    expect(AdminSet.where(title: admin_set_title).count).to eq 1
  end
  it "won't make a second admin set with the same title, it will just return the one that exists already" do
    w.load_superusers
    a = w.make_admin_set(admin_set_title)
    expect(a).to be_instance_of AdminSet
    expect(AdminSet.where(title: admin_set_title).count).to eq 1
    b = w.make_admin_set(admin_set_title)
    expect(b).to be_instance_of AdminSet
    expect(AdminSet.where(title: admin_set_title).count).to eq 1
  end
  it "loads and activates the workflows" do
    w.load_superusers
    a = w.make_admin_set(admin_set_title)
    expect(AdminSet.where(title: admin_set_title).count).to eq 1
    expect(a.permission_template.available_workflows.where(name: "emory_one_step_approval").count).to eq 1
    w.activate_mediated_deposit(a)
    expect(a.active_workflow.name).to eq "emory_one_step_approval"
  end
  it "makes a mediated deposit admin set" do
    new_title = "A Different Title"
    w.make_superuser(superuser_uid)
    admin_set = w.make_mediated_deposit_admin_set(new_title)
    expect(admin_set).to be_instance_of AdminSet
    expect(AdminSet.where(title: new_title).count).to eq 1
    expect(admin_set.active_workflow.name).to eq "emory_one_step_approval"
  end

  context "admin_set config" do
    it "has an array of all the admin_sets" do
      expect(w.admin_sets).to include("Laney Graduate School", "Emory College", "Candler School of Theology")
      config = YAML.safe_load(File.read(Rails.root.join('config', 'authorities', 'rollins_programs.yml')))
      rollins_programs = config["terms"].map { |a| a["id"] }
      rollins_programs.each do |program_name|
        next if program_name == "Environmental Health"
        expect(w.admin_sets).to include(program_name)
      end
    end
    it "has config options for each admin_set" do
      expect(w.admin_set_config("Laney Graduate School")).to be_instance_of Hash
    end
    it "raises an error if it can't find an expected config" do
      expect { w.admin_set_config("foobar") }.to raise_error(RuntimeError, /Couldn't find expected config/)
    end
    context "school specific configs" do
      it "loads approvers from a config" do
        w.load_superusers
        admin_set = w.make_admin_set_from_config("Candler School of Theology")
        workflow = admin_set.active_workflow
        expect(workflow.name).to eq "emory_one_step_approval"
        approving_role = Sipity::Role.where(name: "approving").first
        wf_role = Sipity::WorkflowRole.find_by(workflow: workflow, role_id: approving_role)
        approving_agents = wf_role.workflow_responsibilities.pluck(:agent_id)
        expect(approving_agents.count).to eq 3 # 1 admin_set_owner + 2 approvers from the file
      end
    end
  end
  context "gives superusers superpowers" do
    it "gives superusers the managing role in all newly created admin sets" do
      w.load_superusers
      expect(w.superusers.count).to be > 1 # This test won't be meaningful if there is only one superuser
      admin_set = w.make_mediated_deposit_admin_set("River School")
      workflow = admin_set.permission_template.available_workflows.where(active: true).first
      expect(workflow).to be_instance_of Sipity::Workflow
      w.give_superusers_superpowers
      w.superusers.each do |su|
        roles = Hyrax::Workflow::PermissionQuery.scope_processing_workflow_roles_for_user_and_workflow(user: su, workflow: workflow).pluck(:role_id)
        su_role_names = roles.map { |r| Sipity::Role.where(id: r).first.name }
        expect(su_role_names.include?("managing")).to eq true
      end
    end
    it "knows what users are enrolled in a given role for a given admin_set" do
      w.load_superusers
      laney_admin_set = w.make_admin_set_from_config("Laney Graduate School")
      expect(laney_admin_set.permission_template.available_workflows.where(active: true).first.name).to eq "laney_graduate_school"
      laney_approvers = w.users_in_role(laney_admin_set, "approving")
      expect(laney_approvers.count).to eq 3
      expect(laney_approvers).to be_instance_of Array
      expect(laney_approvers.first).to be_instance_of Sipity::Agent
      laney_approvers = laney_approvers.map { |u| User.find(u.proxy_for_id).uid }
      expect(laney_approvers.include?("laneyadmin")).to eq true
      expect(laney_approvers.include?("laneyadmin2")).to eq true
    end
    it "gives superusers reviewing and approving roles in the Laney workflow without removing existing laney admins" do
      w.load_superusers
      expect(w.superusers.count).to be > 1 # This test won't be meaningful if there is only one superuser
      admin_set = w.make_admin_set_from_config("Laney Graduate School")
      workflow = admin_set.permission_template.available_workflows.where(active: true).first
      expect(workflow).to be_instance_of Sipity::Workflow
      w.give_superusers_superpowers
      w.superusers.each do |su|
        roles = Hyrax::Workflow::PermissionQuery.scope_processing_workflow_roles_for_user_and_workflow(user: su, workflow: workflow).pluck(:role_id)
        su_role_names = roles.map { |r| Sipity::Role.where(id: r).first.name }
        expect(su_role_names.include?("reviewing")).to eq true
        expect(su_role_names.include?("approving")).to eq true
      end
      laney_admin_user = User.where(uid: "laneyadmin").first
      roles = Hyrax::Workflow::PermissionQuery.scope_processing_workflow_roles_for_user_and_workflow(user: laney_admin_user, workflow: workflow).pluck(:role_id)
      la_role_names = roles.map { |r| Sipity::Role.where(id: r).first.name }
      expect(la_role_names.include?("reviewing")).to eq true
      expect(la_role_names.include?("approving")).to eq true
    end
  end

  it "allows any registered user to deposit anywhere" do
    ActiveFedora::Cleaner.clean!
    User.delete_all
    expect(User.count).to eq 0
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
    expect(Sipity::Agent.where(proxy_for_type: "Hyrax::Group").first.proxy_for_id).to eq "registered"
  end

  context "Laney Graduate School workflow" do
    before do
      ActiveFedora::Cleaner.clean!
      User.delete_all
    end
    let(:w) { described_class.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/laney_admin_sets.yml", "/dev/null") }
    let(:etd) { build :etd }
    let(:user) { create :user }
    it "loads a special laney workflow" do
      w.load_superusers
      laney_admin_set = w.make_admin_set_from_config("Laney Graduate School")
      expect(laney_admin_set.active_workflow.name).to eq "laney_graduate_school"
    end
    it "has the expected workflow states and roles" do
      w.load_superusers
      laney_admin_set = w.make_admin_set_from_config("Laney Graduate School")
      workflow = laney_admin_set.active_workflow
      workflow_states = Sipity::WorkflowState.where(workflow_id: workflow.id).pluck(:name)
      expect(workflow_states.include?("pending_review")).to eq true
      expect(workflow_states.include?("pending_approval")).to eq true
      expect(Sipity::Role.where(name: "reviewing").first).to be_instance_of Sipity::Role
    end
    it "assigns the right roles for everyone" do
      w.setup
      workflow = AdminSet.where(title: ["Laney Graduate School"]).first.active_workflow

      # Newly created users should be able to deposit, but nothing else
      depositor = FactoryBot.create(:user, groups: "registered")
      roles = Hyrax::Workflow::PermissionQuery.scope_processing_workflow_roles_for_user_and_workflow(user: depositor, workflow: workflow).pluck(:role_id)
      depositor_role_names = roles.map { |r| Sipity::Role.where(id: r).first.name }
      expect(depositor_role_names.include?("depositing")).to eq true
      expect(depositor_role_names.include?("managing")).to eq false
      expect(depositor_role_names.include?("reviewing")).to eq false
      expect(depositor_role_names.include?("approving")).to eq false

      # Laney admins should have reviewing and approving roles
      laneyadmin = ::User.where(uid: "laneyadmin").first
      roles = Hyrax::Workflow::PermissionQuery.scope_processing_workflow_roles_for_user_and_workflow(user: laneyadmin, workflow: workflow).pluck(:role_id)
      laneyadmin_role_names = roles.map { |r| Sipity::Role.where(id: r).first.name }
      expect(laneyadmin_role_names.include?("depositing")).to eq true
      expect(laneyadmin_role_names.include?("managing")).to eq false
      expect(laneyadmin_role_names.include?("reviewing")).to eq true
      expect(laneyadmin_role_names.include?("approving")).to eq true

      # Very helpful to print out the roles of all users
      # User.all.each do |user|
      #   puts "-----"
      #   puts user.uid
      #   roles = Hyrax::Workflow::PermissionQuery.scope_processing_workflow_roles_for_user_and_workflow(user: user, workflow: workflow).pluck(:role_id)
      #   puts roles.map { |r| Sipity::Role.where(id: r).first.name }
      # end

      # Superusers should have the managing role
      w.superusers.each do |su|
        roles = Hyrax::Workflow::PermissionQuery.scope_processing_workflow_roles_for_user_and_workflow(user: su, workflow: workflow).pluck(:role_id)
        su_role_names = roles.map { |r| Sipity::Role.where(id: r).first.name }
        expect(su_role_names.include?("managing")).to eq true
      end
    end
  end
  context "creating all the admin sets" do
    before do
      ActiveFedora::Cleaner.clean!
      User.delete_all
    end
    let(:w) { described_class.new("#{fixture_path}/config/emory/superusers.yml", Rails.root.join('config', 'emory', 'admin_sets.yml'), "/dev/null") }
    it "doesn't miss any" do
      allow(w).to receive(:load_workflows)
      allow(w).to receive(:load_superusers)
      allow(w).to receive(:everyone_can_deposit_everywhere)
      allow(w).to receive(:give_superusers_superpowers)
      allow(w).to receive(:activate_mediated_deposit)
      w.setup
      expected = w.admin_sets_config.keys
      found = AdminSet.all.map(&:title).map(&:first)
      expect(found).to match_array(expected)
    end
  end
end
