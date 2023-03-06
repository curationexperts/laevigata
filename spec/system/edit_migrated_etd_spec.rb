# frozen_string_literal: true
require 'rails_helper'
require 'workflow_setup'

RSpec.feature 'Edit a migrated ETD, whose department doesn\'t exist anymore',
              :perform_jobs,
              :clean,
              :js,
              integration: true,
              type: :system do
  let(:depositing_user) { FactoryBot.create(:user) }
  let(:approving_user) { User.where(uid: "laneyadmin").first }
  let(:file) { FactoryBot.create(:primary_uploaded_file, user_id: depositing_user.id) }
  let(:default_admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
  let(:default_admin_set) { AdminSet.find(default_admin_set_id) }
  let(:etd) do
    FactoryBot.build(
      :sample_data,
      school: ["Rollins School of Public Health"],
      department: ["Biostatistics and Bioinformatics"],
      subfield: ["Biostatistics"],
      degree: ["MPH"],
      submitting_type: ["Master's Thesis"],
      depositor: depositing_user.user_key,
      admin_set_id: default_admin_set_id
    )
  end
  let(:admin) { FactoryBot.create(:admin) }

  context 'an admin user edits an existing ETD' do
    before do
      allow(CharacterizeJob).to receive(:perform_later) # There is no fits installed on travis-ci
      attributes_for_actor = { uploaded_files: [file.id] }
      env = Hyrax::Actors::Environment.new(etd, ::Ability.new(depositing_user), attributes_for_actor)
      Hyrax::CurationConcern.actor.create(env)
    end

    scenario "it keeps all expected values even if they don't exist in our current controlled vocabulary" do
      expect(etd.active_workflow.name).to eq "default"
      login_as admin
      visit "/concern/etds/#{etd.id}?locale=en"
      click_on "Edit"
      expect(etd.department).to eq ["Biostatistics and Bioinformatics"]
      expect(page).to have_content "Biostatistics and Bioinformatics"
      expect(etd.degree).to eq ["MPH"]
      expect(page).to have_content "MPH"
      expect(etd.subfield).to eq ["Biostatistics"]
      expect(page).to have_content "Biostatistics"
      expect(page).to have_content "Master's Thesis"
      click_on "Submit Your Thesis or Dissertation"
      expect(page).to have_content "Biostatistics and Bioinformatics"

      etd.reload

      expect(etd.department).to eq ["Biostatistics and Bioinformatics"]
      expect(etd.subfield).to eq ["Biostatistics"]
      expect(etd.degree).to eq ["MPH"]
    end
  end
end
