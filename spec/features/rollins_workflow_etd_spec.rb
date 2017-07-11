# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'
require 'active_fedora/cleaner'
require 'workflow_setup'
include Warden::Test::Helpers

RSpec.feature 'Create a Rollins ETD' do
  let(:user) { create :user }
  let(:w) { WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/epidemiology_admin_sets.yml", "/dev/null") }
  let(:superuser) { w.superusers.first }
  context 'a logged in user' do
    before do
      ActiveFedora::Cleaner.clean!
      w.setup
      login_as user
      visit("/concern/etds/new")
    end
    # weak test of the fields but it was failing due to webkit issues with attach_file
    scenario "Miranda submits school and department", js: true do
      select("Rollins School of Public Health", from: "School")
      select("Epidemiology", from: "Department", match: :first)
    end
    scenario "Miranda submits a thesis and an approver approves it", js: true do
      fill_in 'Student Name', with: 'Park, Miranda'
      select("Rollins School of Public Health", from: "School")
      select("Epidemiology", from: "Department")

      select('CDC', from: 'Partnering agency')
      check('agreement')
      click_on('About My ETD')
      title = "Global Public Health #{rand}"
      fill_in 'Title', with: title
      click_on('My PDF')
      within('#fileupload') do
        page.attach_file('files[]', "#{fixture_path}/miranda/miranda_thesis.pdf")
      end
      # TODO: Miranda fixture folder has supplementary files. Add these when we're ready
      click_on('Save')
      expect(page).to have_content title
      expect(page).to have_content 'Pending approval'

      # Check the ETD was assigned the right workflow
      etd = Etd.where(title: [title]).first
      expect(etd.active_workflow.name).to eq "emory_one_step_approval"
      expect(etd.to_sipity_entity.reload.workflow_state_name).to eq "pending_approval"

      # Check workflow permissions for depositing user
      available_workflow_actions = Hyrax::Workflow::PermissionQuery.scope_permitted_workflow_actions_available_for_current_state(user: user, entity: etd.to_sipity_entity).pluck(:name)
      expect(available_workflow_actions.include?("mark_as_reviewed")).to eq false
      expect(available_workflow_actions.include?("approve")).to eq false
      expect(available_workflow_actions.include?("request_changes")).to eq false
      expect(available_workflow_actions.include?("comment_only")).to eq false
      expect(available_workflow_actions.include?("hide")).to eq false
      expect(available_workflow_actions.include?("unhide")).to eq false

      # Check notifications for depositing user
      visit("/notifications?locale=en")
      expect(page).to have_content "#{title} (#{etd.id}) was deposited by #{user.display_name} and is awaiting approval."

      # Check notifications for approving user
      logout
      approving_user = User.where(uid: "epidemiology_admin").first
      login_as approving_user
      visit("/notifications?locale=en")
      expect(page).to have_content "#{title} (#{etd.id}) was deposited by #{user.display_name} and is awaiting approval."

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
      expect(page).to have_content "#{title} (#{etd.id}) has been approved by"

      # Check notifications for depositor again
      logout
      login_as user
      visit("/notifications?locale=en")
      expect(page).to have_content "#{title} (#{etd.id}) has been approved by"
    end
  end
end
