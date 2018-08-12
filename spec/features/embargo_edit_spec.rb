require 'rails_helper'
require 'workflow_setup'
include Warden::Test::Helpers

RSpec.feature 'edit an embargo', :perform_jobs, :js, :new_ui, integration: true do
  before(:all) do
    DatabaseCleaner.clean
    ActiveFedora::Cleaner.clean!

    workflow_settings = { superusers_config: "#{fixture_path}/config/emory/superusers.yml",
                          admin_sets_config: "#{fixture_path}/config/emory/candler_admin_sets.yml",
                          log_location:      "/dev/null" }

    setup_args = [workflow_settings[:superusers_config],
                  workflow_settings[:admin_sets_config],
                  workflow_settings[:log_location]]

    WorkflowSetup.new(*setup_args).setup
  end

  after(:all) do
    DatabaseCleaner.clean
    ActiveFedora::Cleaner.clean!
  end

  let(:attributes) do
    { 'title' => ['The Adventures of Cottontail Rabbit'],
      'post_graduation_email' => ['me@after.graduation.com'],
      'creator' => ['Sneddon, River'],
      'abstract' => ["This is an abstract"],
      'table_of_contents' => ['My table of contents'],
      'school' => ["Candler School of Theology"],
      'department' => ["Divinity"],
      'embargo_length' => '6 months',
      'embargo_type' =>  "files_embargoed, toc_embargoed, abstract_embargoed",
      'uploaded_files' => [uploaded_file.id] }
  end
  let(:actor)      { Hyrax::CurationConcern.actor }
  let(:ability)    { ::Ability.new(user) }
  let(:etd)        { FactoryBot.build(:etd) }
  let(:terminator) { Hyrax::Actors::Terminator.new }
  let(:user)       { FactoryBot.create(:user) }
  let(:env)        { Hyrax::Actors::Environment.new(etd, ability, attributes) }
  let(:open)       { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
  let(:restricted) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
  let(:uploaded_file) do
    FactoryBot.create :primary_uploaded_file, user_id: user.id
  end
  let(:six_years_from_today) { Time.zone.today + 6.years }
  let(:approving_user) { User.find_by(uid: "candleradmin") }

  before do
    allow(CharacterizeJob).to receive(:perform_later) # There is no fits installed on travis-ci
    allow(Hyrax::Workflow::DegreeAwardedNotification).to receive(:send_notification)
    actor.create(env)
    etd.reload
    expect(etd.degree_awarded).to eq nil
    expect(etd.embargo.embargo_release_date).to eq six_years_from_today
    expect(etd.embargo_length).to eq "6 months"
    expect(etd.reload.file_sets.first.embargo)
      .to have_attributes embargo_release_date: six_years_from_today,
                          visibility_during_embargo: restricted,
                          visibility_after_embargo: open
    expect(etd.file_sets.first)
      .to have_attributes visibility: restricted
  end

  scenario "Approver can change the embargo settings" do
    login_as approving_user
    visit("/embargoes/#{etd.id}/edit")
    expect(find('#etd_visibility_during_embargo').find(:xpath, 'option[1]').text).to eq 'All Restricted'
    find('#etd_embargo_release_date')
    fill_in 'etd_embargo_release_date', with: (Time.zone.today + 8.years).to_s
    execute_script('$("form").submit()')
    expect(page).to have_current_path("/concern/etds/#{etd.id}?locale=en")
    expect(page).to have_content etd.title.first
    expect(page).to have_content "successfully updated"
    expect(page).to have_content etd.abstract.first
    expect(page).to have_content etd.table_of_contents.first
    expect(etd.reload.file_sets.first.embargo.embargo_release_date).to eq etd.reload.embargo_release_date
  end
end
