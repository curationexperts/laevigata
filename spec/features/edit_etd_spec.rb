# Generated via `rails generate hyrax:work Etd`
require 'rails_helper'

include Warden::Test::Helpers

RSpec.feature 'Edit an existing ETD', :perform_jobs do
  let(:approver) { User.where(uid: "tezprox").first }
  let(:student) { create :user }

  let(:etd) { FactoryBot.build(:etd, attrs) }
  let(:primary_pdf_file) { File.join(fixture_path, "joey/joey_thesis.pdf") }

  let(:attach_supp_files) { false }
  let(:supplementary_file) { File.join(fixture_path, "nasa.jpeg") }
  let(:supp_file_attrs) do
    { user: student,
      pcdm_use: 'supplementary',
      title: 'supp file title',
      description: 'description of supp file',
      file_type: 'Image' }
  end

  let(:attrs) do
    {
      depositor: student.user_key,
      title: ['Another great thesis by Frodo'],
      creator: ['Johnson, Frodo'],
      graduation_date: ['Spring 2018'],
      post_graduation_email: ['frodo@example.com'],
      school: ['Laney Graduate School'],
      department: [dept],
      subfield: subfield,
      degree: ['Ph.D.'],
      submitting_type: ['Dissertation'],
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

  let(:cc_attrs) { [{ name: 'Fred' }] }
  let(:cm_attrs) { [{ name: 'Barney' }] }

  let(:workflow_setup) { WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/laney_admin_sets.yml", "/dev/null") }

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

    if attach_supp_files
      uploaded_supp = File.open(supplementary_file) { |file| Hyrax::UploadedFile.create(supp_file_attrs.merge(file: file)) }
      file_ids << uploaded_supp.id
    end

    actor = Hyrax::CurationConcern.actor(etd, ::Ability.new(student))
    attributes_for_actor = { uploaded_files: file_ids }
    actor.create(attributes_for_actor)

    # Approver requests changes, so student will be able to edit the ETD
    change_workflow_status(etd, "request_changes", approver)

    # Don't run background jobs during the spec
    allow(ActiveJob::Base).to receive_messages(perform_later: nil, perform_now: nil)
  end

  context 'a logged in student' do
    before { login_as student }

    context "No supplemental files, no embargo, and a department without any subfield" do
      let(:dept) { 'Hispanic Studies' }
      let(:subfield) { nil }

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
        sleep(5)
        # Verify correct Department is selected and not disabled, Sub Fields is disabled
        expect(find('#etd_department').value).to eq dept
        expect(find('#etd_department')).not_to be_disabled
        expect(find('#etd_subfield')).to be_disabled

        # Verify that 'no supplemental files' is checked and 'supplemental files' tab is marked valid.
        click_on('Supplemental Files')
        expect(find_field(id: 'etd_no_supplemental_files').checked?).to be true
        expect(page).to have_css('li#required-supplemental-files.complete')

        # The metadata fields should not be visible since there are no files.
        expect(page).not_to have_content('Required Metadata')

        # Verify that 'no embargoes' is checked and 'embargoes' tab is marked valid.
        click_on('Embargoes')
        expect(find_field(id: 'no_embargoes').checked?).to be true
        expect(find_by_id('embargo_type')).to be_disabled
        expect(find_by_id('embargo_type').value).to eq ''
        expect(find_by_id('embargo_school')).to be_disabled
        expect(find_by_id('etd_embargo_length')).to be_disabled
        expect(page).to have_css('li#required-embargoes.complete')

        # A Laney student should not see the Partnering Agency content
        expect(page).not_to have_content('Partnering Agency')
        expect(page).not_to have_css('#etd_partnering_agency')
      end
    end

    context "An existing ETD" do
      let(:dept) { 'Biological and Biomedical Sciences' }
      let(:subfield) { ['Genetics and Molecular Biology'] }
      let(:attach_supp_files) { true }
      let(:embargo_attrs) do
        {
          files_embargoed: true,
          abstract_embargoed: true,
          toc_embargoed: true,
          embargo_length: '6 months'
        }
      end

      scenario "edit a field", js: true do
        visit hyrax_etd_path(etd)
        click_on('Edit')
        sleep(5)
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
        expect(find('#etd\[committee_chair_attributes\]\[0\]\_affiliation')).to be_disabled
        expect(find('#etd\[committee_chair_attributes\]\[0\]\_affiliation').value).to eq 'Emory'

        # Check fields for Committee Member
        expect(find_field(id: 'no_committee_members').checked?).to be false
        expect(find_field("Committee Member's Affiliation").value).to eq 'Emory Committee Member'
        expect(find_field("Committee Member's Affiliation")).not_to be_disabled
        expect(find_field(id: 'etd[committee_members_attributes][0]_name').value).to eq cm_attrs.first[:name]
        expect(find_field(id: 'etd[committee_members_attributes][0]_name')).not_to be_disabled
        expect(find('#etd\[committee_members_attributes\]\[0\]\_affiliation')).to be_disabled
        expect(find('#etd\[committee_members_attributes\]\[0\]\_affiliation').value).to eq 'Emory'

        # Verify existing data in About My ETD tab
        click_on('My ETD')
        expect(find_field('Title').value).to eq attrs[:title].first
        expect(find_field('Title')).not_to be_disabled
        expect(find_field('Language').value).to eq attrs[:language].first
        expect(find_field('Language')).not_to be_disabled
        within_frame('etd_abstract_ifr') do
          expect(page).to have_content 'Literature from the US'
        end
        within_frame('etd_table_of_contents_ifr') do
          within('h1') do
            expect(page).to have_content 'Chapter One'
          end
        end
        expect(find_field('Research Field').value).to eq attrs[:research_field].first
        expect(find_field('Research Field')).not_to be_disabled
        expect(find_field('Keyword').value).to eq attrs[:keyword].first
        expect(find_field('Keyword')).not_to be_disabled

        # Verify copyright questions
        expect(find_field(id: 'etd_copyright_question_one_true').checked?).to be false
        # TODO: capybara draws these checkboxes differently from Firefox, and doesn't mark them as checked, even though it works properly in the browser.  Is this a bug in capybara?
        # expect(find_field(id: 'etd_copyright_question_one_false').checked?).to be true
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
        # The javascript expects to find the file in '#primary_file_name'
        within('#primary_file_name') do
          expect(page).to have_content 'joey_thesis.pdf'
        end
        # The file upload buttons should be hidden
        expect(page).to have_css('#fileupload', visible: :hidden)
        expect(page).to have_css('#fileupload-browse-everything', visible: :hidden)

        # Verify existing data in Supplemental Files tab
        click_on('Supplemental Files')
        within('#supplemental_fileupload tbody.files tr') do
          expect(page).to have_content('nasa.jpeg')
        end
        expect(page).to have_content('Required Metadata')
        within('#supplemental_files_metadata tbody tr') do
          expect(page).to have_content('nasa.jpeg')
          expect(page).to have_content('supp file title')
          expect(page).to have_content('description of supp file')
          expect(page).to have_content('Image')
        end

        # Verify existing data in Embargoes tab
        click_on('Embargoes')
        expect(find_by_id('no_embargoes').checked?).to be false
        expect(find_by_id('no_embargoes')).not_to be_disabled
        expect(find_by_id('embargo_type').value).to eq '[:files_embargoed, :toc_embargoed, :abstract_embargoed]'
        expect(find_by_id('embargo_type')).not_to be_disabled
        expect(find_by_id('embargo_school').value).to eq 'Laney Graduate School'
        expect(find_by_id('embargo_school')).not_to be_disabled
        expect(find_by_id('etd_embargo_length').value).to eq embargo_attrs[:embargo_length]
        expect(find_by_id('etd_embargo_length')).not_to be_disabled

        # Verify Review tab
        click_on('Review & Submit')
        expect(find('#submission-agreement').visible?).to eq true
        expect(find_field(id: 'agreement').checked?).to be true
        expect(find('#with_files_submit')).not_to be_disabled
        expect(page).to have_content 'Generate Preview'

        # All tabs in the form should be marked as valid so that the student can edit the fields and save the new data.
        expect(page).to have_css('li#required-about-me.complete')
        expect(page).to have_css('li#required-my-etd.complete')
        expect(page).to have_css('li#required-files.complete')
        expect(page).to have_css('li#required-supplemental-files.complete')
        expect(page).to have_css('li#required-embargoes.complete')
        expect(page).to have_css('li#required-review.complete')

        # The student edits some data in the form
        click_on('About Me')
        select 'Chemistry', from: 'Department'
        # Subfield should change according to department
        expect(find_field('Sub Field', disabled: true)).to be_disabled

        # Edit a committee member
        fill_in 'etd[committee_members_attributes][0]_name', with: 'Betty'

        # The tab should stil be valid with the new data.
        expect(page).to have_css('li#required-about-me.complete')

        # The student previews their changes
        click_on('Review & Submit')
        expect(page).not_to have_content('Chemistry')
        find("#preview_my_etd").click
        expect(page).to have_content('Chemistry')

        # Make sure supplemental files table is correct
        within('#review') do
          expect(page).to have_content('nasa.jpeg')
          expect(page).to have_content('supp file title')
          expect(page).to have_content('description of supp file')
          expect(page).to have_content('Image')
        end

        # Save the form
        click_on('Submit My ETD')

        # Make sure that new data appears on ETD show page
        expect(current_path.gsub('?locale=en', '')).to eq hyrax_etd_path(etd)
        expect(page).to have_content 'Department Chemistry'
        expect(page).not_to have_content 'Subfield'
        expect(page).to have_content 'Committee Members Betty'
      end
    end
  end
end
