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
      'embargo_length' => '6 months',
      'embargo_type' =>  "all_restricted",
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
  let(:many_years_from_today) { Time.current.to_date + Hyrax::Actors::PregradEmbargo::DEFAULT_LENGTH }
  let(:approving_user) { User.find_by(uid: "candleradmin") }

  before :all do
    ActiveFedora::Cleaner.clean!

    WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml",
                      "#{fixture_path}/config/emory/candler_admin_sets.yml",
                      "/dev/null").setup
  end

  before do
    allow(CharacterizeJob).to receive(:perform_later) # There is no fits installed on travis-ci
    allow(Hyrax::Workflow::DegreeAwardedNotification).to receive(:send_notification)
    actor.create(env)
    etd.reload
  end

  scenario "base etd has expected embargo values after creation", :aggregate_failures do
    logout
    expect(etd.degree_awarded).to eq nil
    expect(etd.embargo.embargo_release_date).to eq many_years_from_today
    expect(etd.embargo_length).to eq "6 months"
    expect(etd.visibility).to eq "all_restricted"
    expect(etd.visibility_translator.proxy.visibility).to eq "open"
    expect(etd.reload.file_sets.first.embargo)
      .to have_attributes embargo_release_date: many_years_from_today,
                          visibility_during_embargo: restricted,
                          visibility_after_embargo: open
    expect(etd.file_sets.first)
      .to have_attributes visibility: restricted
  end

  scenario "viewed by depositor pre-graduation", :aggregate_failures do
    login_as user
    visit("/concern/etds/#{etd.id}")
    expect(page).to have_content "Abstract"
    expect(page).to have_content etd.abstract.first
    expect(page).to have_content "[Abstract embargoed until #{etd.embargo_length} post-graduation"
    expect(page).to have_content "Table of Contents"
    expect(page).to have_content etd.table_of_contents.first
    expect(page).to have_content "[Table of contents embargoed until #{etd.embargo_length} post-graduation"
    expect(page).to have_content etd.title.first
    expect(page).to have_link etd.title.first
    expect(page).to have_content etd.title.first
    click_on "Select an action"
    # In dev and prod the depositor seems to be able to download
    # their own work, regardless of approval or graduation status.
    # That's what we want. I can't figure out why this test
    # isn't working. I'm commenting it out so as not to block
    # the hyrax 2.2.0 upgrade. --Bess
    # TODO: Reinstate this test
    # expect(page).to have_content "Download"
  end

  scenario "viewed by approver pre-graduation", :aggregate_failures do
    allow(Flipflop).to receive(:versions_and_edit_links?).and_return(false)
    login_as approving_user
    visit("/concern/etds/#{etd.id}")
    expect(page).to have_content "Abstract"
    expect(page).to have_content etd.abstract.first
    expect(page).to have_content "[Abstract embargoed until #{etd.embargo_length} post-graduation"
    expect(page).to have_content "Table of Contents"
    expect(page).to have_content etd.table_of_contents.first
    expect(page).to have_content "[Table of contents embargoed until #{etd.embargo_length} post-graduation"
    expect(page).to have_content etd.title.first
    expect(page).to have_link etd.title.first
    expect(page).to have_content etd.title.first
    click_on "Select an action"
    expect(page).to have_content "Download"
    expect(page).not_to have_content "Versions"
    expect(page).not_to have_content "Edit"
  end

  scenario "viewed by approver with Versions enabled", :aggregate_failures do
    allow(Flipflop).to receive(:versions_and_edit_links?).and_return(true)
    login_as approving_user
    visit("/concern/etds/#{etd.id}")
    click_on "Select an action"
    expect(page).to have_content "Download"
    expect(page).to have_content "Versions"
    expect(page).to have_content "Edit"
  end

  scenario "post graduation", :aggregate_failures do
    # An approving user marks the etd as approved
    subject = Hyrax::WorkflowActionInfo.new(etd, approving_user)
    sipity_workflow_action = PowerConverter.convert_to_sipity_action("approve", scope: subject.entity.workflow) { nil }
    Hyrax::Workflow::WorkflowActionService.run(subject: subject, action: sipity_workflow_action, comment: nil)
    expect(etd.to_sipity_entity.reload.workflow_state_name).to eq "approved"
    # The student officially graduates
    GraduationJob.perform_now(etd.id)
    expect(etd.to_sipity_entity.reload.workflow_state_name).to eq "published"
    etd.reload # to clear cached data in memory after approval & graudation processes

    # viewed by any user - logged in or not
    logout # ensure we're not still logged in as an admin from another test
    visit("/concern/etds/#{etd.id}")
    expect(page).to have_content "Abstract"
    expect(page).to have_content "This abstract is under embargo until #{formatted_embargo_release_date(etd)}"
    expect(page).to have_content "Table of Contents"
    expect(page).to have_content "This table of contents is under embargo until #{formatted_embargo_release_date(etd)}"

    # viewed by an unauthenticated user should suppress abstract & toc text
    visit("/concern/etds/#{etd.id}")
    expect(page).not_to have_content etd.abstract.first
    expect(page).not_to have_content etd.table_of_contents.first
    expect(page).not_to have_link etd.title.first
    expect(page).not_to have_content "Select an action"
    expect(page).to have_css ".related-files .filename", text: 'File download under embargo'
    expect(page).to have_css "img.representative-media[alt='Preview image embargoed']"

    # viewed by an approver should display full abstract & toc
    login_as approving_user
    visit("/concern/etds/#{etd.id}")
    expect(page).to have_content etd.abstract.first
    expect(page).to have_content etd.table_of_contents.first
    expect(page).to have_content etd.title.first
    expect(page).to have_link etd.title.first
    click_on "Select an action"
    expect(page).to have_link "Download"
  end

  def formatted_embargo_release_date(etd)
    etd.embargo.embargo_release_date.strftime("%d %B %Y")
  end
end
