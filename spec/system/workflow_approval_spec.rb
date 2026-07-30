# frozen_string_literal: true
require 'rails_helper'
require 'workflow_setup'

RSpec.describe 'Approval workflow', :clean, :js, integration: true, type: :system do
  let(:approving_user)  { User.find_by(uid: "candleradmin") }
  let(:depositing_user) { FactoryBot.create(:user) }
  let(:primary_file) { FactoryBot.create(:primary_uploaded_file, user_id: depositing_user.id) }

  let(:etd) do
    FactoryBot.create(:sample_data, school: ["Candler School of Theology"], user: depositing_user)
  end

  before do
    WorkflowSetup
      .new("#{fixture_path}/config/emory/superusers.yml",
           "#{fixture_path}/config/emory/candler_admin_sets.yml",
           "/dev/null")
      .setup

    allow(CharacterizeJob).to receive(:perform_later) # There is no fits installed on travis-ci
    attributes_for_actor = { uploaded_files: [primary_file.id] }
    env = Hyrax::Actors::Environment.new(etd, ::Ability.new(depositing_user), attributes_for_actor)
    Hyrax::CurationConcern.actor.create(env)
    etd.reload
  end

  scenario 'requesting and approving changes', :perform_jobs, :aggregate_failures do
    expect(etd.active_workflow.name).to eq 'emory_one_step_approval'
    expect(etd.to_sipity_entity.reload.workflow_state_name).to eq 'pending_approval'

    login_as approving_user
    visit hyrax.admin_workflows_path

    expect(page).to have_link(text: etd.title.first)
    expect(page).to have_content etd.creator.first
    expect(page).to have_content 'Pending Approval'

    click_on etd.title.first

    expect(page).to have_link 'Review and Approval'
    click_on 'Review and Approval'
    choose 'workflow_action_name_request_changes'
    fill_in 'workflow_action_comment', with: 'Please update your PDF'
    click_on 'Submit'
    expect(page).to have_current_path(hyrax_etd_path(etd))
    expect(page).to have_content 'The ETD has been updated.'

    login_as depositing_user
    visit hyrax_etd_path(etd)
    click_on 'Review and Approval'
    expect(page).to have_content 'Please update your PDF'
    click_on 'Edit'
    debugger
    attach_file('etd_files[]', "#{fixture_path}/joey/joey_thesis.pdf")
    click_on 'Submit Your Thesis or Dissertation'



  end
end
