# Generated via `rails generate hyrax:work Etd`
require 'rails_helper'

include Warden::Test::Helpers

RSpec.feature 'Edit an existing ETD' do
  # using an admin in this test because they will see the edit button in the show view and be allowed to edit
  let(:admin_superuser) { User.where(uid: "tezprox").first }
  let(:student) { create :user }

  let(:etd) { FactoryGirl.build(:etd, attrs) }
  let(:primary_pdf_file) { File.join(fixture_path, "joey/joey_thesis.pdf") }

  let(:attrs) do
    {
      depositor: student.user_key,
      title: ['Another great thesis by Frodo'],
      creator: ['Johnson, Frodo'],
      graduation_date: ['Spring 2018'],
      post_graduation_email: ['frodo@example.com'],
      school: ['Emory College'],
      department: [dept],
      subfield: subfield,
      degree: ['PhD'],
      submitting_type: ['Dissertation'],
      committee_chair_attributes: cc_attrs,
      committee_members_attributes: cm_attrs,
      language: ['English'],
      abstract: ['Literature from the US'],
      table_of_contents: ['Chapter One'],
      research_field: ['Aeronomy'],
      keyword: ['key1'],
      copyright_question_one: false,
      copyright_question_two: true,
      copyright_question_three: false,
      no_supplemental_files: supp_files,
    }
  end

  let(:cc_attrs) { [{ name: 'Fred' }] }
  let(:cm_attrs) { [{ name: 'Barney' }] }
  let(:supp_files) { false }

  let(:workflow_setup) { WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/ec_admin_sets.yml", "/dev/null") }

  before do
    # Create AdminSet and Workflow
    ActiveFedora::Cleaner.clean!
    workflow_setup.setup

    # Don't characterize the file during specs
    allow(CharacterizeJob).to receive_messages(perform_later: nil, perform_now: nil)

    etd.assign_admin_set
    ability = ::Ability.new(student)
    upload = File.open(primary_pdf_file) { |file| Hyrax::UploadedFile.create(user: student, file: file, pcdm_use: 'primary') }
    actor = Hyrax::CurationConcern.actor(etd, ability)
    attributes_for_actor = { uploaded_files: [upload.id] }
    actor.create(attributes_for_actor)

    # Don't run background jobs during the spec
    allow(ActiveJob::Base).to receive_messages(perform_later: nil, perform_now: nil)
  end

  context 'a logged in admin_superuser' do
    before { login_as admin_superuser }

    context "A department without any subfield" do
      let(:dept) { 'African American Studies' }
      let(:subfield) { nil }

      scenario "on the edit form", js: true do
        visit hyrax_etd_path(etd)
        click_on('Edit')

        # Verify correct Department is selected and not disabled, Sub Fields is disabled
        expect(find('#etd_department').value).to eq dept
        expect(find('#etd_department')).not_to be_disabled
        expect(find('#etd_subfield')).to be_disabled
      end
    end

    context "An existing ETD" do
      let(:dept) { 'Biology' }
      let(:subfield) { ['Genetics and Molecular Biology'] }

      scenario "edit a field", js: true do
        visit hyrax_etd_path(etd)
        click_on('Edit')

        # TODO: Verify that all our data appears on the form and that the fields are editable.

        dept_field = find('#etd_department')
        subfield_field = find('#etd_subfield')

        # Verify correct Department and Sub Fields are selected and not disabled
        expect(dept_field.value).to eq dept
        expect(subfield_field.value).to eq subfield.first
        expect(dept_field).not_to be_disabled
        expect(subfield_field).not_to be_disabled

        # Edit some data in the form
        select 'Chemistry', from: 'Department'
        # Subfield should change according to department
        expect(subfield_field.value).to eq ''

        # TODO:
        # The form should allow the student to save the new data, even though we only edited one field.
        # expect(page).to have_css('li#required-about-me.complete')
        # expect(page).to have_css('li#required-my-etd.complete')
        # expect(page).to have_css('li#required-files.complete')
        # expect(page).to have_css('li#required-supplemental-files.complete')
        # expect(page).to have_css('li#required-embargoes.complete')
        # expect(page).to have_css('li#required-review.complete')

        # TODO:
        # Save the form
        # click_on('Review & Submit')
        # check('agreement')
        # click_button 'Save'
        # wait_for_ajax

        # TODO:
        # Check our new values appear on the show page
        # expect(page).to have_content 'Department Chemistry'
        # expect(page).not_to have_content 'Subfield'
      end
    end
  end
end
