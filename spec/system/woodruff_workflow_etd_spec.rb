# frozen_string_literal: true
require 'rails_helper'
require 'workflow_setup'

RSpec.describe 'Woodruff approval workflow', :perform_jobs, :clean, integration: true, type: :system do
  let(:depositing_user) { FactoryBot.create(:user) }
  let(:approving_user) { User.where(uid: "woodruffadmin").first }
  let(:admin_superuser) { User.where(uid: "tezprox").first } # uid from superuser.yml

  let(:w) { WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/woodruff_admin_sets.yml", "/dev/null") }

  let(:etd) do
    FactoryBot.actor_create(
      :sample_data,
      school: ["Nell Hodgson Woodruff School of Nursing"],
      department: ["Family NP"],
      user: depositing_user
    )
  end

  context 'a logged in user' do
    before { w.setup }

    scenario "a school approver approves a work" do
      # Check the ETD was assigned the right workflow
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

      # once the work is approved, only the admin set owner should be able to publish
      # Approvers should *not* have a publish option
      available_workflow_actions = Hyrax::Workflow::PermissionQuery.scope_permitted_workflow_actions_available_for_current_state(user: approving_user, entity: etd.to_sipity_entity).pluck(:name)
      expect(available_workflow_actions.include?("publish")).to eq false

      # Check notifications for approving user
      visit("/notifications?locale=en")
      expect(page).to have_content "Deposit #{etd.title.first} has been approved"
      expect(page).to have_content "#{etd.title.first}\" deposited by #{depositing_user.display_name} has been approved by"

      # Check notifications for depositor again
      logout
      login_as depositing_user
      visit("/notifications?locale=en")
      expect(page).to have_content "Deposit #{etd.title.first} has been approved"
      expect(page).to have_content "#{etd.title.first}\" deposited by #{depositing_user.display_name} has been approved by"

      # Depositing user should be able to see their work, even if it hasn't been approved yet
      visit("/concern/etds/#{etd.id}")
      expect(page).to have_content(etd.abstract.first)
      expect(page).not_to have_content("The work is not currently available because it has not yet completed the publishing process")

      # Visit the ETD as a public user. It should not be visible.
      logout
      visit("/concern/etds/#{etd.id}")
      expect(page).to have_content "The work is not currently available because it has not yet completed the publishing process"

      # Publish the ETD via the GraduationJob
      GraduationJob.perform_now(etd.id, Time.zone.yesterday)

      # Now the work should be publicly visible
      visit("/concern/etds/#{etd.id}")
      expect(page).not_to have_content "The work is not currently available because it has not yet completed the publishing process"

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
