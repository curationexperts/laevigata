# Generated via `rails generate hyrax:work Etd`
require 'rails_helper'

include Warden::Test::Helpers

RSpec.feature 'Edit an existing ETD' do
  let(:approver) { User.where(uid: "tezprox").first }
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
      degree: ['Ph.D.'],
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
      no_supplemental_files: no_supp_files,
      files_embargoed: embargo_attrs[:files_embargoed],
      abstract_embargoed: embargo_attrs[:abstract_embargoed],
      toc_embargoed: embargo_attrs[:toc_embargoed],
      embargo_length: embargo_attrs[:embargo_length]
    }
  end

  let(:cc_attrs) { [{ name: 'Fred' }] }
  let(:cm_attrs) { [{ name: 'Barney' }] }

  let(:workflow_setup) { WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/ec_admin_sets.yml", "/dev/null") }

  before do
    ActiveFedora::Cleaner.clean!

    # Create AdminSet and Workflow
    workflow_setup.setup

    # Don't characterize the file during specs
    allow(CharacterizeJob).to receive_messages(perform_later: nil, perform_now: nil)

    # Create ETD & attach PDF file
    etd.assign_admin_set
    upload = File.open(primary_pdf_file) { |file| Hyrax::UploadedFile.create(user: student, file: file, pcdm_use: 'primary') }
    actor = Hyrax::CurationConcern.actor(etd, ::Ability.new(student))
    attributes_for_actor = { uploaded_files: [upload.id] }
    actor.create(attributes_for_actor)

    # Approver requests changes, so student will be able to edit the ETD
    change_workflow_status(etd, "request_changes", approver)

    # Don't run background jobs during the spec
    allow(ActiveJob::Base).to receive_messages(perform_later: nil, perform_now: nil)
  end

  context 'a logged in student' do
    before { login_as student }

    context "No supplemental files, no embargo, and a department without any subfield" do
      let(:dept) { 'African American Studies' }
      let(:subfield) { nil }
      let(:no_supp_files) { true }

      let(:embargo_attrs) do
        {
          files_embargoed: false,
          abstract_embargoed: false,
          toc_embargoed: false,
          embargo_length: nil
        }
      end

      scenario "on the edit form", js: true do
        visit hyrax_etd_path(etd)
        click_on('Edit')

        # Verify correct Department is selected and not disabled, Sub Fields is disabled
        expect(find('#etd_department').value).to eq dept
        expect(find('#etd_department')).not_to be_disabled
        expect(find('#etd_subfield')).to be_disabled

        # Verify that 'no supplemental files' is checked
        click_on('Supplemental Files')
        expect(find_field(id: 'etd_no_supplemental_files').checked?).to be true

        # Verify that 'no embargoes' is checked
        click_on('Embargoes')
        # TODO:
        # expect(find_field(id: 'no_embargoes').checked?).to be true
        # expect(find_field(id: 'embargo_type')).to be_disabled
        # expect(find_field(id: 'embargo_school')).to be_disabled
        # expect(find_field(id: 'etd_embargo_length')).to be_disabled
      end
    end

    context "An existing ETD" do
      let(:dept) { 'Biology' }
      let(:subfield) { ['Genetics and Molecular Biology'] }
      let(:no_supp_files) { false }

      let(:embargo_attrs) do
        {
          files_embargoed: true,
          abstract_embargoed: true,
          toc_embargoed: true,
          embargo_length: '6 months'
        }
      end

      # TODO: Attach supplemental files to the ETD in a before block so we can validate that they appear correctly on the Supplemental Files tab.

      scenario "edit a field", js: true do
        visit hyrax_etd_path(etd)
        click_on('Edit')

        # Verify existing data in About Me tab
        expect(find_field('Student Name').value).to eq attrs[:creator].first
        expect(find_field('Student Name')).not_to be_disabled
        expect(find_field('Graduation Date').value).to eq attrs[:graduation_date].first
        expect(find_field('Graduation Date')).not_to be_disabled
        expect(find_field('Post Graduation Email').value).to eq attrs[:post_graduation_email].first
        expect(find_field('Post Graduation Email')).not_to be_disabled
        expect(find_field('School').value).to eq attrs[:school].first
        expect(find_field('School')).not_to be_disabled
        expect(find_field('Department').value).to eq attrs[:department].first
        expect(find_field('Department')).not_to be_disabled
        expect(find_field('Sub Field').value).to eq attrs[:subfield].first
        expect(find_field('Sub Field')).not_to be_disabled
        expect(find_field('Degree').value).to eq attrs[:degree].first
        expect(find_field('Degree')).not_to be_disabled
        expect(find_field('Submission Type').value).to eq attrs[:submitting_type].first
        expect(find_field('Submission Type')).not_to be_disabled

        # Check fields for Committee Chair
        expect(find_field("Committee Chair/Thesis Advisor's Affiliation").value).to eq 'Emory Committee Chair'
        expect(find_field("Committee Chair/Thesis Advisor's Affiliation")).not_to be_disabled
        expect(find_field(id: 'etd[committee_chair_attributes][0]_name').value).to eq cc_attrs.first[:name]
        expect(find_field(id: 'etd[committee_chair_attributes][0]_name')).not_to be_disabled
        # TODO: expect(find_field(id: 'etd[committee_chair_attributes][0]_affiliation').value).to eq 'Emory'
        # TODO: expect(find_field(id: 'etd[committee_chair_attributes][0]_affiliation')).to be_disabled

        # Check fields for Committee Member
        expect(find_field("Committee Member's Affiliation").value).to eq 'Emory Committee Member'
        expect(find_field("Committee Member's Affiliation")).not_to be_disabled
        expect(find_field(id: 'etd[committee_members_attributes][0]_name').value).to eq cm_attrs.first[:name]
        expect(find_field(id: 'etd[committee_members_attributes][0]_name')).not_to be_disabled
        # TODO: expect(find_field(id: 'etd[committee_members_attributes][0]_affiliation').value).to eq 'Emory'
        # TODO: expect(find_field(id: 'etd[committee_members_attributes][0]_affiliation')).to be_disabled

        # Verify existing data in About My ETD tab
        click_on('My ETD')
        expect(find_field('Title').value).to eq attrs[:title].first
        expect(find_field('Title')).not_to be_disabled
        expect(find_field('Language').value).to eq attrs[:language].first
        expect(find_field('Language')).not_to be_disabled
        # TODO: abstract - Add some html tags to the data and make sure they appear or don't appear correctly in the edit field
        # TODO: table_of_contents - Add some html tags to the data and make sure they appear or don't appear correctly in the edit field
        expect(find_field('Research Field').value).to eq attrs[:research_field].first
        expect(find_field('Research Field')).not_to be_disabled
        expect(find_field('Keyword').value).to eq attrs[:keyword].first
        expect(find_field('Keyword')).not_to be_disabled

        # Verify copyright questions
        expect(find_field(id: 'etd_copyright_question_one_true').checked?).to be false
        # TODO: expect(find_field(id: 'etd_copyright_question_one_false').checked?).to be true
        expect(find_field(id: 'etd_copyright_question_one_true')).not_to be_disabled
        expect(find_field(id: 'etd_copyright_question_one_false')).not_to be_disabled

        expect(find_field(id: 'etd_copyright_question_two_true').checked?).to be true
        expect(find_field(id: 'etd_copyright_question_two_false').checked?).to be false
        expect(find_field(id: 'etd_copyright_question_two_true')).not_to be_disabled
        expect(find_field(id: 'etd_copyright_question_two_false')).not_to be_disabled

        expect(find_field(id: 'etd_copyright_question_three_true').checked?).to be false
        # TODO: expect(find_field(id: 'etd_copyright_question_three_false').checked?).to be true
        expect(find_field(id: 'etd_copyright_question_three_true')).not_to be_disabled
        expect(find_field(id: 'etd_copyright_question_three_false')).not_to be_disabled

        click_on('My PDF')
        # TODO: Verify existing data in My PDF tab

        click_on('Supplemental Files')
        # TODO: Verify existing data in Supplemental Files tab

        # TODO: Verify existing data in Embargoes tab
        click_on('Embargoes')
        expect(find_field(id: 'no_embargoes').checked?).to be false
        expect(find_field(id: 'no_embargoes')).not_to be_disabled
        # TODO: expect(find_field(id: 'embargo_type').value).to eq 'Files, Table of Contents and Abstract'
        expect(find_field(id: 'embargo_type')).not_to be_disabled
        # TODO: expect(find_field(id: 'embargo_school').value).to eq 'TBD'
        expect(find_field(id: 'embargo_school')).not_to be_disabled
        expect(find_field(id: 'etd_embargo_length').value).to eq embargo_attrs[:embargo_length]
        expect(find_field(id: 'etd_embargo_length')).not_to be_disabled

        # TODO: Verify existing data in Review tab - maybe nothing?

        # TODO:
        # All tabs in the form should be marked as valid so that the student can edit the fields and save the new data.
        expect(page).to have_css('li#required-about-me.complete')
        # expect(page).to have_css('li#required-my-etd.complete')
        # expect(page).to have_css('li#required-files.complete')
        # expect(page).to have_css('li#required-supplemental-files.complete')
        # expect(page).to have_css('li#required-embargoes.complete')
        # expect(page).to have_css('li#required-review.complete')

        # The student edits some data in the form
        click_on('About Me')
        select 'Chemistry', from: 'Department'
        # Subfield should change according to department
        expect(find_field('Sub Field').value).to eq ''

        # TODO: Maybe edit Abstract or Table of Contents to make sure the markup gets saved properly.

        # TODO:
        # Save the form
        # click_on('Review & Submit')
        # check('agreement')
        # click_button 'Save'
        # wait_for_ajax

        # TODO:
        # Check that the new values appear on the show page
        # expect(page).to have_content 'Department Chemistry'
        # expect(page).not_to have_content 'Subfield'
      end
    end
  end
end
