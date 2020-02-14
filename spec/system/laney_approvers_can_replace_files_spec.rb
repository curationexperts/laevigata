# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'
require 'workflow_setup'
include Warden::Test::Helpers

RSpec.feature 'Laney approvers can replace files',
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
      Hyrax::CurationConcern.actor.create(env)
    end

    scenario "an approver wants to replace a file on a pending_approval work" do
      expect(etd.active_workflow.name).to eq "laney_graduate_school"
      expect(etd.to_sipity_entity.reload.workflow_state_name).to eq "pending_review"

      login_as approving_user

      # The approving user marks the etd as reviewed
      subject = Hyrax::WorkflowActionInfo.new(etd, approving_user)
      sipity_workflow_action = PowerConverter.convert_to_sipity_action("mark_as_reviewed", scope: subject.entity.workflow) { nil }
      Hyrax::Workflow::WorkflowActionService.run(subject: subject, action: sipity_workflow_action, comment: nil)
      expect(etd.to_sipity_entity.reload.workflow_state_name).to eq "pending_approval"

      visit("/concern/etds/#{etd.id}")
      expect(etd.edit_users).to include(approving_user.user_key)
    end
  end
end
