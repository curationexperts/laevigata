# frozen_string_literal: true
require 'rails_helper'
require 'workflow_setup'

RSpec.feature 'Edit an existing ETD',
              :perform_jobs,
              :clean,
              :js,
              integration: true,
              type: :system do
  let(:depositing_user) { FactoryBot.create(:user) }
  let(:approving_user) { User.where(uid: "laneyadmin").first }
  let(:file) { FactoryBot.create(:primary_uploaded_file, user_id: depositing_user.id) }
  let(:w) { WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/rollins_subset_admin_sets.yml", "/dev/null") }
  let(:etd) { FactoryBot.create(:sample_data, school: ["Rollins School of Public Health"], department: ["Biostatistics"], subfield: ["Biostatistics"], depositor: depositing_user.user_key) }
  let(:admin_superuser) { User.where(uid: "tezprox").first } # uid from superuser.yml

  context 'an admin user' do
    before do
      allow(CharacterizeJob).to receive(:perform_later) # There is no fits installed on travis-ci
      w.setup
      attributes_for_actor = { uploaded_files: [file.id] }
      env = Hyrax::Actors::Environment.new(etd, ::Ability.new(depositing_user), attributes_for_actor)
      Hyrax::CurationConcern.actor.create(env)
    end

    scenario "edits an existing ETD" do
      expect(etd.active_workflow.name).to eq "emory_one_step_approval"
      expect(etd.to_sipity_entity.reload.workflow_state_name).to eq "pending_approval"
      login_as admin_superuser
      visit "/concern/etds/#{etd.id}?locale=en"
      click_on "Edit"
      expect(page).to have_content "Biostatistics and Bioinformatics"
      expect(page).to have_content etd.degree.first
      expect(page).to have_content "Biostatistics - MPH & MSPH"
      click_on "Submit Your Thesis or Dissertation"
      expect(page).to have_content "Biostatistics and Bioinformatics"
      expect(page).to have_content etd.degree.first
      expect(page).to have_content "Biostatistics - MPH & MSPH"
    end
  end
end
