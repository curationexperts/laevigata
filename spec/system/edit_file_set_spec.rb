# frozen_string_literal: true
require 'rails_helper'
require 'workflow_setup'

RSpec.describe 'Display an ETD with embargoed content', :perform_jobs, :js, integration: true, type: :system do
  let(:attributes) do
    { 'title' => ['The Adventures of Cottontail Rabbit'],
      'post_graduation_email' => ['me@after.graduation.com'],
      'creator' => ['Sneddon, River'],
      'abstract' => ["This is an abstract"],
      'table_of_contents' => ['My table of contents'],
      'school' => ["Candler School of Theology"],
      'department' => ["Divinity"],
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
    DatabaseCleaner.clean
    ActiveFedora::Cleaner.clean!

    workflow_settings = { superusers_config: "#{fixture_path}/config/emory/superusers.yml",
                          admin_sets_config: "#{fixture_path}/config/emory/candler_admin_sets.yml",
                          log_location:      "/dev/null" }

    setup_args = [workflow_settings[:superusers_config],
                  workflow_settings[:admin_sets_config],
                  workflow_settings[:log_location]]

    WorkflowSetup.new(*setup_args).setup
    allow(CharacterizeJob).to receive(:perform_later) # There is no fits installed on travis-ci
    allow(Hyrax::Workflow::DegreeAwardedNotification).to receive(:send_notification)
    actor.create(env)
  end

  scenario "a student can access the file set edit form when a work has had changes requested" do
    # The approving user asks for changes so the student can edit the work
    subject = Hyrax::WorkflowActionInfo.new(etd, approving_user)
    sipity_workflow_action = PowerConverter.convert_to_sipity_action("request_changes", scope: subject.entity.workflow) { nil }
    Hyrax::Workflow::WorkflowActionService.run(subject: subject, action: sipity_workflow_action, comment: nil)
    expect(etd.to_sipity_entity.reload.workflow_state_name).to eq "changes_required"
    etd.reload
    login_as user
    visit main_app.edit_hyrax_file_set_path(etd.primary_file_fs.first.id)
    expect(find_field('Title').value).to eq etd.title.first
  end
end
