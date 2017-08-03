# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'
require 'active_fedora/cleaner'
require 'workflow_setup'
include Warden::Test::Helpers

RSpec.feature 'Laney Graduate School two step approval workflow' do
  let(:depositing_user) { User.where(ppid: etd.depositor).first }
  let(:approving_user) { User.where(uid: "laneyadmin").first }
  let(:w) { WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/laney_admin_sets.yml", "/dev/null") }
  let(:etd) { FactoryGirl.create(:sample_data, school: ["Laney Graduate School"]) }
  context 'a logged in user' do
    before do
      allow(CharacterizeJob).to receive(:perform_later) # There is no fits installed on travis-ci
      ActiveFedora::Cleaner.clean!
      w.setup
      actor = Hyrax::CurationConcern.actor(etd, ::Ability.new(depositing_user))
      actor.create({})
    end
    scenario "an approver reviews and approves a work" do
      expect(etd.active_workflow.name).to eq "laney_graduate_school"
      expect(etd.to_sipity_entity.reload.workflow_state_name).to eq "pending_review"

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
      expect(page).to have_content 'Deposit needs review'
      expect(page).to have_content "#{etd.title.first} (#{etd.id}) was deposited by #{depositing_user.display_name} and is awaiting initial review."

      # Check notifications for approving user
      logout
      login_as approving_user
      visit("/notifications?locale=en")
      expect(page).to have_content 'Deposit needs review'
      expect(page).to have_content "#{etd.title.first} (#{etd.id}) was deposited by #{depositing_user.display_name} and is awaiting initial review."

      # Check workflow permissions for approving user
      available_workflow_actions = Hyrax::Workflow::PermissionQuery.scope_permitted_workflow_actions_available_for_current_state(user: approving_user, entity: etd.to_sipity_entity).pluck(:name)
      expect(available_workflow_actions.include?("mark_as_reviewed")).to eq true
      expect(available_workflow_actions.include?("approve")).to eq false # it can't be approved until after it has been marked as reviewed
      expect(available_workflow_actions.include?("request_changes")).to eq true
      expect(available_workflow_actions.include?("comment_only")).to eq true
      expect(available_workflow_actions.include?("hide")).to eq true
      expect(available_workflow_actions.include?("unhide")).to eq true

      # Last superuser should have all workflow options available. (First superuser gets these by virtue of owning the admin sets.)
      expect(w.superusers.count).to be > 1 # This test is meaningless if there is only one superuser
      available_workflow_actions = Hyrax::Workflow::PermissionQuery.scope_permitted_workflow_actions_available_for_current_state(user: w.superusers.last, entity: etd.to_sipity_entity).pluck(:name)
      expect(available_workflow_actions.include?("mark_as_reviewed")).to eq true
      expect(available_workflow_actions.include?("approve")).to eq false # it can't be approved until after it has been marked as reviewed
      expect(available_workflow_actions.include?("request_changes")).to eq true
      expect(available_workflow_actions.include?("comment_only")).to eq true
      expect(available_workflow_actions.include?("hide")).to eq true
      expect(available_workflow_actions.include?("unhide")).to eq true

      # The approving user marks the etd as reviewed
      subject = Hyrax::WorkflowActionInfo.new(etd, approving_user)
      sipity_workflow_action = PowerConverter.convert_to_sipity_action("mark_as_reviewed", scope: subject.entity.workflow) { nil }
      Hyrax::Workflow::WorkflowActionService.run(subject: subject, action: sipity_workflow_action, comment: nil)
      expect(etd.to_sipity_entity.reload.workflow_state_name).to eq "pending_approval"

      # Check notifications for approving user
      visit("/notifications?locale=en")
      expect(page).to have_content "#{etd.title.first} (#{etd.id}) has completed initial review and is awaiting final approval."

      # The approving user marks the etd as approved
      subject = Hyrax::WorkflowActionInfo.new(etd, approving_user)
      sipity_workflow_action = PowerConverter.convert_to_sipity_action("approve", scope: subject.entity.workflow) { nil }
      Hyrax::Workflow::WorkflowActionService.run(subject: subject, action: sipity_workflow_action, comment: nil)
      expect(etd.to_sipity_entity.reload.workflow_state_name).to eq "approved"

      # The approving user hides the ETD
      expect(etd.hidden?).to eq false
      sipity_workflow_action = PowerConverter.convert_to_sipity_action("hide", scope: subject.entity.workflow) { nil }
      Hyrax::Workflow::WorkflowActionService.run(subject: subject, action: sipity_workflow_action, comment: "hiding for reasons")
      expect(etd.to_sipity_entity.reload.workflow_state_name).to eq "approved" # workflow state has not changed
      expect(etd.hidden?).to eq true

      # The approving user unhides the ETD
      sipity_workflow_action = PowerConverter.convert_to_sipity_action("unhide", scope: subject.entity.workflow) { nil }
      Hyrax::Workflow::WorkflowActionService.run(subject: subject, action: sipity_workflow_action, comment: "unhiding for reasons")
      expect(etd.to_sipity_entity.reload.workflow_state_name).to eq "approved" # workflow state has not changed
      expect(etd.hidden?).to eq false

      # Check notifications for approving user
      visit("/notifications?locale=en")
      expect(page).to have_content "#{etd.title.first} (#{etd.id}) has been approved by"
      expect(page).to have_content "#{etd.title.first} (#{etd.id}) was hidden by"
      expect(page).to have_content "hiding for reasons"
      expect(page).to have_content "#{etd.title.first} (#{etd.id}) was unhidden by"
      expect(page).to have_content "unhiding for reasons"

      # Check notifications for depositor again
      logout
      login_as depositing_user
      visit("/notifications?locale=en")
      expect(page).to have_content "#{etd.title.first} (#{etd.id}) has completed initial review and is awaiting final approval."
      expect(page).to have_content "#{etd.title.first} (#{etd.id}) has been approved by"

      # Depositing user should be able to see their work, even if it hasn't been approved yet
      visit("/concern/etds/#{etd.id}")
      expect(page).to have_content(etd.abstract.first)
      expect(page).not_to have_content("The work is not currently available")

      # Visit the ETD as a public user. It should not be visible.
      logout
      visit("/concern/etds/#{etd.id}")
      expect(page).to have_content "The work is not currently available"

      # Run the graduation service
      allow(GraduationService).to receive(:check_degree_status).and_return(Time.zone.today)
      GraduationService.run

      # Now the work should be publicly visible
      visit("/concern/etds/#{etd.id}")
      expect(page).not_to have_content "The work is not currently available"

      # Check for graduation notifications
      login_as depositing_user
      visit("/notifications?locale=en")
      expect(page).to have_content "Degree awarded for #{etd.title.first}"

      # Check graduation notifications for approving user
      logout
      login_as approving_user
      visit("/notifications?locale=en")
      expect(page).to have_content "Degree awarded for #{etd.title.first}"
    end
  end
end
