require 'rails_helper'
require 'workflow_setup'
include Warden::Test::Helpers

RSpec.feature 'Dashboard workflow', :clean, integration: true do
  let(:approving_user)  { User.find_by(uid: "candleradmin") }
  let(:depositing_user) { FactoryBot.create(:user) }

  let(:etd) do
    FactoryBot.actor_create(:sample_data, school: ["Candler School of Theology"], user: depositing_user)
  end

  before do
    WorkflowSetup
      .new("#{fixture_path}/config/emory/superusers.yml",
           "#{fixture_path}/config/emory/candler_admin_sets.yml",
           "/dev/null")
      .setup
    login_as approving_user
  end

  scenario 'approver can approve submitted etd', :perform_jobs do
    expect(etd.active_workflow.name).to eq 'emory_one_step_approval'
    expect(etd.to_sipity_entity.reload.workflow_state_name).to eq 'pending_approval'

    visit '/dashboard'
    click_on 'Review Submissions'

    expect(page).to have_content etd.title.first
    expect(page).to have_content etd.contributor.first
    expect(page).to have_content 'pending_approval'
  end
end
