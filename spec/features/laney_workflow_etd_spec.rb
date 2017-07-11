# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'
require 'active_fedora/cleaner'
require 'workflow_setup'
include Warden::Test::Helpers

RSpec.feature 'Create a Laney ETD' do
  let(:user) { create :user }
  let(:w) { WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/laney_admin_sets.yml", "/dev/null") }
  let(:superuser) { w.superusers.first }
  context 'a logged in user' do
    before do
      ActiveFedora::Cleaner.clean!
      w.setup
      login_as user
      visit("/concern/etds/new")
    end
    # weak test of the fields but it was failing due to webkit issues with attach_file
    scenario "Joey submits submits school and department", js: true do
      select("Laney Graduate School", from: "School")
      select("Religion", from: "Department", match: :first)
    end

    scenario "Joey submits a thesis and an approver reviews and approves it" do
      expect(page).not_to have_css('input#etd_title.multi_value')
      expect(page).to have_css('input#etd_creator')
      expect(page).not_to have_css('input#etd_creator.multi_value')
      fill_in 'Student Name', with: 'Coppola, Joey'
      # fill_in 'Keyword', with: 'Surrealism'
      # Department is not required, by default it is hidden as an additional field
      select('CDC', from: 'Partnering agency')
      check('agreement')

      click_on('About My ETD')
      expect(page).to have_css('#about_my_etd input#etd_title')
      title = "Surrealism #{rand}"
      fill_in 'Title', with: title

      click_on('My PDF')
      page.attach_file('files[]', "#{fixture_path}/joey/joey_thesis.pdf")
      click_on("Review")
      select("Laney Graduate School", from: "Add as member of administrative set")
      click_on('Save')
      expect(page).to have_content title
      expect(page).to have_content 'Pending review'

      # Check the ETD was assigned the right workflow
      etd = Etd.where(title: [title]).first
      expect(etd.active_workflow.name).to eq "laney_graduate_school"
      expect(etd.to_sipity_entity.reload.workflow_state_name).to eq "pending_review"

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
      expect(page).to have_content 'Deposit needs review'
      expect(page).to have_content "#{title} (#{etd.id}) was deposited by #{user.display_name} and is awaiting initial review."

      # Check notifications for approving user
      logout
      approving_user = User.where(uid: "laneyadmin").first
      login_as approving_user
      visit("/notifications?locale=en")
      expect(page).to have_content 'Deposit needs review'
      expect(page).to have_content "#{title} (#{etd.id}) was deposited by #{user.display_name} and is awaiting initial review."

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
      expect(page).to have_content "#{title} (#{etd.id}) has completed initial review and is awaiting final approval."

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
      expect(page).to have_content "#{title} (#{etd.id}) has been approved by"
      expect(page).to have_content "#{title} (#{etd.id}) was hidden by"
      expect(page).to have_content "hiding for reasons"
      expect(page).to have_content "#{title} (#{etd.id}) was unhidden by"
      expect(page).to have_content "unhiding for reasons"

      # Check notifications for depositor again
      logout
      login_as user
      visit("/notifications?locale=en")
      screenshot_and_open_image
      expect(page).to have_content "#{title} (#{etd.id}) has completed initial review and is awaiting final approval."
      expect(page).to have_content "#{title} (#{etd.id}) has been approved by"
    end
  end
end
