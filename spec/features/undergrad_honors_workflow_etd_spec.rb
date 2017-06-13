# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'
require 'active_fedora/cleaner'
require 'workflow_setup'
include Warden::Test::Helpers

RSpec.feature 'Create an Emory College ETD' do
  let(:user) { create :user }
  let(:w) { WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/", "#{::Rails.root}/config/emory/schools.yml", "/dev/null") }
  let(:superuser) { w.superusers.first }
  context 'a logged in user' do
    before do
      ActiveFedora::Cleaner.clean!
      w.setup
      login_as user
    end

    scenario "Noah submits a thesis and an approver approves it", js: true do
      visit("/concern/etds/new")
      expect(page).to have_css('input#etd_title.required')
      expect(page).not_to have_css('input#etd_title.multi_value')
      expect(page).to have_css('input#etd_creator.required')
      expect(page).not_to have_css('input#etd_creator.multi_value')
      title = "A Brief History of Art #{rand}"
      fill_in 'Title', with: title
      fill_in 'Student Name', with: 'Washburn, Noah'
      select("Emory College", from: "School")
      expect(page).not_to have_selector(:css, "#etd_department[disabled]", wait: 10)
      select("Art History", from: "Department")
      choose('open')
      check('agreement')
      click_on('My PDF')
      page.attach_file('files[]', "#{fixture_path}/noah/noah_thesis.pdf")
      # TODO: Miranda fixture folder has supplementary files. Add these when we're ready
      click_on("Review")
      select("Emory College", from: "Add as member of administrative set")
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
      expect(page).to have_content "#{title} (#{etd.id}) was deposited by #{user.email} and is awaiting approval."

      # Check notifications for approving user
      logout
      approving_user = User.where(email: "ecadmin@emory.edu").first
      login_as approving_user
      visit("/notifications?locale=en")
      expect(page).to have_content "#{title} (#{etd.id}) was deposited by #{user.email} and is awaiting approval."

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
