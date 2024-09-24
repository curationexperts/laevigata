# frozen_string_literal: true
require 'rails_helper'
require 'workflow_setup'

RSpec.feature 'Laney Graduate School two step approval workflow',
              :perform_jobs,
              :clean,
              :js,
              integration: true,
              type: :system do
  let(:depositing_user) { FactoryBot.create(:user) }
  let(:approving_user) { User.where(uid: "laneyadmin").first }
  let(:file) { FactoryBot.create(:primary_uploaded_file, user_id: depositing_user.id) }
  let(:w) { WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/laney_admin_sets.yml", "/dev/null") }
  let(:etd) { FactoryBot.create(:sample_data, school: ["Laney Graduate School"], depositor: depositing_user.user_key) }

  context 'a logged in user' do
    before do
      allow(CharacterizeJob).to receive(:perform_later) # There is no fits installed on travis-ci
      w.setup
      attributes_for_actor = { uploaded_files: [file.id] }
      env = Hyrax::Actors::Environment.new(etd, ::Ability.new(depositing_user), attributes_for_actor)

      # stub non-relevant jobs to speed up test
      allow(StreamNotificationsJob).to receive(:perform_later)
      allow(Hyrax::RevokeEditFromMembersJob).to receive(:perform_later)
      allow(Hyrax::GrantReadToMembersJob).to receive(:perform_later)
      Hyrax::CurationConcern.actor.create(env)
    end

    scenario "an approver reviews and approves a work", :aggregate_failures do
      expect(etd.active_workflow.name).to eq "laney_graduate_school"
      expect(etd.to_sipity_entity.reload.workflow_state_name).to eq "pending_review"

      # Check workflow permissions for depositing user
      available_workflow_actions = Hyrax::Workflow::PermissionQuery.scope_permitted_workflow_actions_available_for_current_state(user: depositing_user, entity: etd.to_sipity_entity).pluck(:name)
      expect(available_workflow_actions).to be_empty # after submission, and before any review

      # Check notifications for depositing user
      login_as depositing_user
      visit("/notifications?locale=en")
      expect(page).to have_content 'Deposit needs review'
      expect(page).to have_content "#{etd.title.first} (#{etd.id}) was updated by #{depositing_user.display_name} and is awaiting review & approval."

      # Check notifications for approving user
      logout
      login_as approving_user
      visit("/notifications?locale=en")
      expect(page).to have_content 'Deposit needs review'
      expect(page).to have_content "#{etd.title.first} (#{etd.id}) was updated by #{depositing_user.display_name} and is awaiting review & approval."

      # Check workflow permissions for approving user
      available_workflow_actions = Hyrax::Workflow::PermissionQuery.scope_permitted_workflow_actions_available_for_current_state(user: approving_user, entity: etd.to_sipity_entity).pluck(:name)
      expect(available_workflow_actions).to contain_exactly(
                                              "comment_only",
                                              "request_changes",
                                              "mark_as_reviewed",
                                              "hide",
                                              "unhide"
                                            )
      # "approve" should not be in the list until after the ETD has been marked as reviewed

      # Last superuser should have all workflow options available. (First superuser gets these by virtue of owning the admin sets.)
      expect(w.superusers.count).to be > 1 # This test is meaningless if there is only one superuser
      available_workflow_actions = Hyrax::Workflow::PermissionQuery.scope_permitted_workflow_actions_available_for_current_state(user: w.superusers.last, entity: etd.to_sipity_entity).pluck(:name)
      expect(available_workflow_actions).to contain_exactly(
                                              "comment_only",
                                              "request_changes",
                                              "mark_as_reviewed",
                                              "hide",
                                              "unhide"
                                            )

      # The approving user marks the etd as reviewed
      change_workflow_status(etd, "mark_as_reviewed", approving_user)
      expect(etd.to_sipity_entity.reload.workflow_state_name).to eq "pending_approval"

      # Check notifications for approving user
      visit("/notifications?locale=en")
      expect(page).to have_content "#{etd.title.first} (#{etd.id}) deposited by #{depositing_user.display_name} has completed initial review and is awaiting final approval."

      # The approving user marks the etd as approved
      change_workflow_status(etd, "approve", approving_user)
      expect(etd.to_sipity_entity.reload.workflow_state_name).to eq "approved"

      # The approving user hides the ETD
      expect(etd.hidden?).to eq false
      change_workflow_status(etd, "hide", approving_user, "hiding for reasons")
      expect(etd.to_sipity_entity.reload.workflow_state_name).to eq "approved" # workflow state has not changed
      expect(etd.hidden?).to eq true
      expect(etd.visibility).to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
      expect(etd.members.first.visibility).to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE

      # The approving user unhides the ETD
      change_workflow_status(etd, "unhide", approving_user, "unhiding for reasons")
      expect(etd.to_sipity_entity.reload.workflow_state_name).to eq "approved" # workflow state has not changed
      expect(etd.hidden?).to eq false
      expect(etd.visibility).to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      expect(etd.members.first.visibility).to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC

      # Check notifications for approving user
      visit("/notifications?locale=en")
      expect(page).to have_content "#{etd.title.first}\" deposited by #{depositing_user.display_name} has been approved by"
      expect(page).to have_content "#{etd.title.first} (#{etd.id}) deposited by #{depositing_user.display_name} was hidden by"
      expect(page).to have_content "hiding for reasons"
      expect(page).to have_content "#{etd.title.first} (#{etd.id}) deposited by #{depositing_user.display_name} was unhidden by"
      expect(page).to have_content "unhiding for reasons"

      # Check notifications for depositor again
      logout
      login_as depositing_user
      visit("/notifications?locale=en")
      expect(page).to have_content "#{etd.title.first} (#{etd.id}) deposited by #{depositing_user.display_name} has completed initial review and is awaiting final approval."
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
      ActiveJob::Base.queue_adapter = :test
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
