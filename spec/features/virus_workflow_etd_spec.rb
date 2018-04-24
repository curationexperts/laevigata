# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'
require 'workflow_setup'
include Warden::Test::Helpers

RSpec.feature 'Virus checking', :perform_jobs, :clean do
  let(:depositing_user) { User.where(ppid: etd.depositor).first }
  let(:approving_user) { User.where(uid: "candleradmin").first }
  let(:admin_superuser) { User.where(uid: "tezprox").first } # uid from superuser.yml
  let(:pdf_path) { "#{fixture_path}/joey/joey_thesis.pdf" }
  let(:upload1) do
    File.open(pdf_path) do |file1|
      Hyrax::UploadedFile.create(user: depositing_user, file: file1, pcdm_use: 'primary')
    end
  end
  let(:w) { WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/candler_admin_sets.yml", "/dev/null") }
  let(:etd) { FactoryBot.create(:sample_data, school: ["Candler School of Theology"]) }
  context 'a logged in user' do
    before do
      allow(CharacterizeJob).to receive(:perform_later) # There is no fits installed on travis-ci
      class_double("Clamby").as_stubbed_const
      allow(Clamby).to receive(:virus?).and_return(true)
      w.setup
      actor = Hyrax::CurationConcern.actor(etd, ::Ability.new(depositing_user))
      attributes_for_actor = { uploaded_files: [upload1.id] }
      actor.create(attributes_for_actor)
    end
    scenario "supplemental file with virus" do
      # Check the ETD was assigned the right workflow
      expect(etd.active_workflow.name).to eq "emory_one_step_approval"
      expect(etd.to_sipity_entity.reload.workflow_state_name).to eq "pending_approval"

      # Check notifications for depositing user
      login_as depositing_user
      visit("/notifications?locale=en")
      expect(page).to have_content "#{etd.title.first} (#{etd.id}) was deposited by #{depositing_user.display_name} and is awaiting approval."
      expect(page).to have_content "Virus encountered"

      # Check notifications for approving user
      logout
      login_as approving_user
      visit("/notifications?locale=en")
      expect(page).to have_content "Virus encountered"

      visit("/concern/etds/#{etd.id}")
      # expect(page).to have_content "Virus detected. File deleted."
    end
  end
end
