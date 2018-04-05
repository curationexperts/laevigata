# Generated via `rails generate hyrax:work Etd`
require 'rails_helper'
require 'active_fedora/cleaner'
require 'workflow_setup'
include Warden::Test::Helpers

RSpec.feature 'Edit an existing ETD', :perform_jobs do
  let(:approver) { User.where(uid: "epidemiology_admin").first }
  let(:student) { create :user }

  let(:etd) { FactoryBot.build(:etd, attrs) }
  let(:primary_pdf_file) { File.join(fixture_path, "joey/joey_thesis.pdf") }

  let(:attrs) do
    {
      depositor: student.user_key,
      title: ['A Rollins thesis by Joey'],
      creator: ['Johnson, Joey'],
      graduation_date: ['Spring 2018'],
      post_graduation_email: ['frodo@example.com'],
      school: ['Rollins School of Public Health'],
      department: ['Epidemiology'],
      subfield: ['Epidemiology - MPH & MSPH'],
      degree: ['Ph.D.'],
      submitting_type: ['Dissertation'],
      partnering_agency: ['CDC'],
      committee_chair_attributes: cc_attrs,
      committee_members_attributes: cm_attrs,
      language: ['English'],
      abstract: ['<p>Literature from the US</p>'],
      table_of_contents: ['<h1>Chapter One</h1>'],
      research_field: ['Aeronomy'],
      keyword: ['key1'],
      copyright_question_one: false,
      copyright_question_two: true,
      copyright_question_three: false,
      files_embargoed: embargo_attrs[:files_embargoed],
      abstract_embargoed: embargo_attrs[:abstract_embargoed],
      toc_embargoed: embargo_attrs[:toc_embargoed],
      embargo_length: embargo_attrs[:embargo_length]
    }
  end

  let(:embargo_attrs) do
    {
      files_embargoed: false,
      abstract_embargoed: false,
      toc_embargoed: false,
      embargo_length: nil
    }
  end

  let(:cc_attrs) { [{ name: 'Fred' }] }
  let(:cm_attrs) { [{ name: 'Barney' }] }

  let(:workflow_setup) { WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/epidemiology_admin_sets.yml", "/dev/null") }

  before do
    ActiveFedora::Cleaner.clean!

    # Create AdminSet and Workflow
    workflow_setup.setup

    # Don't characterize the file during specs
    allow(CharacterizeJob).to receive_messages(perform_later: nil, perform_now: nil)

    # Create ETD & attach PDF file
    etd.assign_admin_set
    uploaded_etd = File.open(primary_pdf_file) { |file| Hyrax::UploadedFile.create(user: student, file: file, pcdm_use: 'primary') }
    file_ids = [uploaded_etd.id]

    actor = Hyrax::CurationConcern.actor(etd, ::Ability.new(student))
    attributes_for_actor = { uploaded_files: file_ids }
    actor.create(attributes_for_actor)

    # Approver requests changes, so student will be able to edit the ETD
    change_workflow_status(etd, "request_changes", approver)

    # Don't run background jobs during the spec
    allow(ActiveJob::Base).to receive_messages(perform_later: nil, perform_now: nil)
  end

  context 'a logged in Rollins student edits their ETD', js: true do
    before { login_as student }

    scenario "and Partnering Agency is displayed" do
      visit hyrax_etd_path(etd)
      click_on('Edit')
      sleep(5)

      expect(page).to have_content('Partnering Agency')
      expect(page).to have_css('#etd_partnering_agency')
      expect(page).to have_css('li#required-about-me.complete')
    end
  end
end
