# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'
require 'active_fedora/cleaner'
require 'workflow_setup'
include Warden::Test::Helpers

RSpec.feature 'Emory College approval workflow' do
  let(:depositing_user) { User.where(ppid: etd.depositor).first }
  let(:approving_user) { User.where(uid: "ecadmin").first }
  let(:w) { WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/ec_admin_sets.yml", "/dev/null") }
  let(:etd) { FactoryGirl.create(:sample_data, school: ["Emory College"]) }
  context 'a logged in user' do
    before do
      allow(CharacterizeJob).to receive(:perform_later) # There is no fits installed on travis-ci
      ActiveFedora::Cleaner.clean!
      w.setup
      actor = Hyrax::CurationConcern.actor(etd, ::Ability.new(depositing_user))
      actor.create({})
    end
    scenario "a school approver approves a work" do
      expect(etd.active_workflow.name).to eq "emory_one_step_approval"
      expect(etd.to_sipity_entity.reload.workflow_state_name).to eq "pending_approval"

      # Check workflow permissions for depositing user
      available_workflow_actions = Hyrax::Workflow::PermissionQuery.scope_permitted_workflow_actions_available_for_current_state(user: depositing_user, entity: etd.to_sipity_entity).pluck(:name)
      expect(available_workflow_actions.include?("mark_as_reviewed")).to eq false
      expect(available_workflow_actions.include?("approve")).to eq false
      expect(available_workflow_actions.include?("request_changes")).to eq false
      expect(available_workflow_actions.include?("comment_only")).to eq false
      expect(available_workflow_actions.include?("hide")).to eq false
      expect(available_workflow_actions.include?("unhide")).to eq false

      # Check notifications for depositing user
      login_as depositing_user
      visit("/notifications?locale=en")
      expect(page).to have_content "#{etd.title.first} (#{etd.id}) was deposited by #{depositing_user.display_name} and is awaiting approval."

      # Check notifications for approving user
      logout
      login_as approving_user
      visit("/notifications?locale=en")
      expect(page).to have_content "#{etd.title.first} (#{etd.id}) was deposited by #{depositing_user.display_name} and is awaiting approval."

      # Check workflow permissions for approving user
      available_workflow_actions = Hyrax::Workflow::PermissionQuery.scope_permitted_workflow_actions_available_for_current_state(user: approving_user, entity: etd.to_sipity_entity).pluck(:name)
      expect(available_workflow_actions.include?("mark_as_reviewed")).to eq false # this workflow step should only exist for Laney
      expect(available_workflow_actions.include?("approve")).to eq true
      expect(available_workflow_actions.include?("request_changes")).to eq true
      expect(available_workflow_actions.include?("comment_only")).to eq true
      expect(available_workflow_actions.include?("hide")).to eq true
      expect(available_workflow_actions.include?("unhide")).to eq true

      # Last superuser should have all workflow options available. (First superuser gets these by virtue of owning the admin sets.)
      expect(w.superusers.count).to be > 1 # This test is meaningless if there is only one superuser
      available_workflow_actions = Hyrax::Workflow::PermissionQuery.scope_permitted_workflow_actions_available_for_current_state(user: w.superusers.last, entity: etd.to_sipity_entity).pluck(:name)
      expect(available_workflow_actions.include?("mark_as_reviewed")).to eq false # this workflow step should only exist for Laney
      expect(available_workflow_actions.include?("approve")).to eq true
      expect(available_workflow_actions.include?("request_changes")).to eq true
      expect(available_workflow_actions.include?("comment_only")).to eq true
      expect(available_workflow_actions.include?("hide")).to eq true
      expect(available_workflow_actions.include?("unhide")).to eq true

      # The approving user marks the etd as approved
      subject = Hyrax::WorkflowActionInfo.new(etd, approving_user)
      sipity_workflow_action = PowerConverter.convert_to_sipity_action("approve", scope: subject.entity.workflow) { nil }
      Hyrax::Workflow::WorkflowActionService.run(subject: subject, action: sipity_workflow_action, comment: nil)
      expect(etd.to_sipity_entity.reload.workflow_state_name).to eq "approved"

      # Check notifications for approving user
      visit("/notifications?locale=en")
      expect(page).to have_content "#{etd.title.first} (#{etd.id}) has been approved by"

      # Check notifications for depositor again
      logout
      login_as depositing_user
      visit("/notifications?locale=en")
      expect(page).to have_content "#{etd.title.first} (#{etd.id}) has been approved by"
    end
  end
end
