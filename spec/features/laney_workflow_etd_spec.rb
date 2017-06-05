# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'
require 'active_fedora/cleaner'
require 'workflow_setup'
include Warden::Test::Helpers

RSpec.feature 'Create a Laney ETD' do
  let(:user) { create :user }
  let(:w) { WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/", "#{::Rails.root}/config/emory/schools.yml", "/dev/null") }
  let(:superuser) { w.superusers.first }
  context 'a logged in user' do
    before do
      ActiveFedora::Cleaner.clean!
      w.setup
      login_as user
    end

    scenario "Joey submits a thesis and an approver reviews and approves it" do
      visit("/concern/etds/new")
      expect(page).to have_css('input#etd_title.required')
      expect(page).not_to have_css('input#etd_title.multi_value')
      expect(page).to have_css('input#etd_creator.required')
      expect(page).not_to have_css('input#etd_creator.multi_value')
      title = "Surrealism #{rand}"
      fill_in 'Title', with: title
      fill_in 'Student Name', with: 'Coppola, Joey'
      fill_in 'Keyword', with: 'Surrealism'
      # Department is not required, by default it is hidden as an additional field
      fill_in "Department", with: "Institute of Liberal Arts"
      fill_in "School", with: "Laney Graduate School"
      select('All rights reserved', from: 'Rights')
      choose('open')
      check('agreement')
      click_on('My PDF')
      # page.attach_file('files[]', "#{fixture_path}/joey/joey_thesis.pdf")
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

      # Check notifications for depositing user
      visit("/notifications?locale=en")
      expect(page).to have_content 'Deposit needs review'
      expect(page).to have_content "#{title} (#{etd.id}) was deposited by #{user.email} and is awaiting initial review."

      # Check notifications for approving user
      logout
      approving_user = User.where(email: "laneyadmin@emory.edu").first
      login_as approving_user
      visit("/notifications?locale=en")
      expect(page).to have_content 'Deposit needs review'
      expect(page).to have_content "#{title} (#{etd.id}) was deposited by #{user.email} and is awaiting initial review."

      # Check workflow permissions for approving user
      available_workflow_actions = Hyrax::Workflow::PermissionQuery.scope_permitted_workflow_actions_available_for_current_state(user: approving_user, entity: etd.to_sipity_entity).pluck(:name)
      expect(available_workflow_actions.include?("mark_as_reviewed")).to eq true
      expect(available_workflow_actions.include?("approve")).to eq false # it can't be approved until after it has been marked as reviewed
      expect(available_workflow_actions.include?("request_changes")).to eq true
      expect(available_workflow_actions.include?("comment_only")).to eq true

      # TODO: second superuser should have all workflow options available. (first superuser gets these by virtue of owning the admin sets)
      # workflow = AdminSet.where(title: ["Laney Graduate School"]).first.permission_template.available_workflows.where(active: true).first
      # User.all.each do |user|
      #   puts "-----"
      #   puts user.email
      #   roles = Hyrax::Workflow::PermissionQuery.scope_processing_workflow_roles_for_user_and_workflow(user: user, workflow: workflow).pluck(:role_id)
      #   puts roles.map { |r| Sipity::Role.where(id: r).first.name }
      # end
      # Check workflow permissions for superuser
      # available_workflow_actions = Hyrax::Workflow::PermissionQuery.scope_permitted_workflow_actions_available_for_current_state(user: w.superusers.last, entity: etd.to_sipity_entity).pluck(:name)
      # puts w.superusers.last
      # puts available_workflow_actions.inspect
      # expect(available_workflow_actions.include?("mark_as_reviewed")).to eq true
      # expect(available_workflow_actions.include?("approve")).to eq false # it can't be approved until after it has been marked as reviewed
      # expect(available_workflow_actions.include?("request_changes")).to eq true
      # expect(available_workflow_actions.include?("comment_only")).to eq true

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

      # Check notifications for approving user
      visit("/notifications?locale=en")
      expect(page).to have_content "#{title} (#{etd.id}) was approved by"

      # Check notifications for depositor again
      logout
      login_as user
      visit("/notifications?locale=en")
      expect(page).to have_content "#{title} (#{etd.id}) has completed initial review and is awaiting final approval."
      expect(page).to have_content "#{title} (#{etd.id}) was approved by"
    end
  end
end
