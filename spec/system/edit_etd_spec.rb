# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'
require 'workflow_setup'
include Warden::Test::Helpers

RSpec.feature 'Edit an existing ETD',
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
      expect(etd.active_workflow.name).to eq "laney_graduate_school"
      expect(etd.to_sipity_entity.reload.workflow_state_name).to eq "pending_review"
      login_as admin_superuser
      visit "/concern/etds/#{etd.id}?locale=en"
      click_on "Edit"
      expect(page).to have_content "Divinity"
      expect(page).to have_content etd.degree.first
      click_on "Submit Your Thesis or Dissertation"
      expect(page).to have_content "Divinity"
      expect(page).to have_content etd.degree.first
    end
  end
end
