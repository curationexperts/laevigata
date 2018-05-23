# Generated via `rails generate hyrax:work Etd`
require 'rails_helper'

include Warden::Test::Helpers

RSpec.feature 'Create an Etd', :clean do
  let(:student) { create :user }

  context 'a logged in user' do
    before do
      login_as student
      visit("/concern/etds/new")
    end

    scenario "View Etd Tabs", js: true do
      expect(page).to have_selector("[data-toggle='tab']", text: "About Me")
      expect(page).to have_selector("[data-toggle='tab']", text: "My ETD")
      expect(page).to have_selector("[data-toggle='tab']", text: "My PDF")
      expect(page).to have_selector("[data-toggle='tab']", text: "Supplemental Files")
      expect(page).to have_selector("[data-toggle='tab']", text: "Embargoes")
      expect(page).to have_selector("[data-toggle='tab']", text: "Review & Submit")
      expect(page).to have_content("Submission Checklist")
      expect(page).not_to have_content("Save Work")
    end

    scenario "Submission Checklist contains all ETD requirement checkboxes" do
      expect(page).to have_selector("li#required-about-me")
      expect(page).to have_selector("li#required-my-etd")
      expect(page).to have_selector("li#required-files")
      expect(page).to have_selector("li#required-supplemental-files")
      expect(page).to have_selector("li#required-embargoes")
    end
  end

  context 'a student (non-admin user)' do
    let(:title) { 'A great thesis by Frodo' }
    let(:workflow_setup) { WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/ec_admin_sets.yml", "/dev/null") }

    before do
      # Don't run background jobs during the spec
      allow(ActiveJob::Base).to receive_messages(perform_later: nil, perform_now: nil)

      # Create AdminSet and Workflow
      workflow_setup.setup

      login_as student
      visit new_hyrax_etd_path
    end

    scenario "Create a new ETD", js: true do
      # When the form first loads, all the tabs should be
      # marked as 'incomplete'.
      expect(page).to have_css('li#required-about-me.incomplete')
      expect(page).to have_css('li#required-my-etd.incomplete')
      expect(page).to have_css('li#required-files.incomplete')
      expect(page).to have_css('li#required-supplemental-files.incomplete')
      expect(page).to have_css('li#required-embargoes.incomplete')
      expect(page).to have_css('li#required-review.incomplete')

      # expect 'About Me' department and subfield to be disabled, as they are dynamically supplied by student's school choice
      expect(find('#etd_department')).to be_disabled
      expect(find('#etd_subfield')).to be_disabled

      # Fill in 'About Me' tab
      fill_in 'Student Name', with: 'Johnson, Frodo'
      select 'Spring 2018', from: 'Graduation Date'
      fill_in 'Post Graduation Email', with: 'frodo@example.com'
      select 'Emory College', from: 'School'
      select 'Religion', from: 'Department'
      select 'Ethics and Society', from: 'Sub Field'
      select 'PhD', from: 'Degree'
      select 'Dissertation', from: 'Submission Type'
      fill_in 'etd[committee_chair_attributes][0]_name', with: 'Fred'
      expect(page).to have_css('li#required-about-me.incomplete')
      fill_in 'etd[committee_members_attributes][0]_name', with: 'Barney'

      # Fill in 'My ETD' tab
      click_on('My ETD')
      expect(page).to have_css('li#required-about-me.complete')
      fill_in 'Title', with: title
      select 'English', from: 'Language'
      tinymce_fill_in('etd_abstract', '<em>Literature</em> from the US')
      tinymce_fill_in('etd_table_of_contents', ' <script>alert("attack!");</script>Chapter One')
      select 'Aeronomy', from: 'Research Field'
      fill_in 'Keyword', with: 'key1'
      expect(page).to have_css('li#required-my-etd.incomplete')
      find('#question_1').choose('No')
      find('#question_2').choose('No')
      find('#question_3').choose('No')
      expect(page).to have_css('li#required-my-etd.complete')

      click_on('My PDF')
      within('#fileupload') do
        page.attach_file('primary_files[]', "#{fixture_path}/miranda/miranda_thesis.pdf", visible: false, wait: 10)
      end
      expect(page).to have_css('li#required-files.complete')

      click_on('Supplemental Files')
      expect(page).to have_css('li#required-supplemental-files.incomplete')
      expect(page).not_to have_content('Required Metadata')
      within('#supplemental_fileupload') do
        page.attach_file('supplemental_files[]', "#{fixture_path}/magic_warrior_cat.jpg", visible: false, wait: 10)
      end
      expect(page).to have_content('Required Metadata')
      fill_in name: 'etd[supplemental_file_metadata][0]title', with: 'supp file title'
      fill_in name: 'etd[supplemental_file_metadata][0]description', with: 'supp file desc'
      select 'Image', from: 'etd[supplemental_file_metadata][0]file_type'
      expect(page).to have_css('li#required-supplemental-files.complete')

      click_on('Embargoes')
      expect(page).to have_css('li#required-embargoes.incomplete')
      check 'I do not want to embargo my thesis or dissertation.'
      expect(page).to have_css('li#required-embargoes.complete')

      # Preview
      click_on('Review & Submit')
      expect(page).not_to have_content('magic_warrior_cat.jpg')
      find(:css, '#preview_my_etd').click
      expect(page).to have_content('magic_warrior_cat.jpg')
      expect(page).to have_content('supp file title')
      expect(page).to have_content('supp file desc')
      expect(page).to have_content('Image')

      # Save the form
      expect(page).to have_css('li#required-review.incomplete')
      check('agreement')
      expect(page).to have_css('li#required-review.complete')
      save_and_wait = -> { click_button "Submit My ETD"; wait_for_ajax(10) }
      expect(save_and_wait).to change { Etd.count }.by(1)
                           .and change { FileSet.count }.by(0)

      # Find our newly-created ETD
      etds = Etd.where(title_tesim: title)
      expect(etds.length).to eq 1 # Make sure only 1 ETD in array
      etd = etds.first

      # The student views his ETD
      visit hyrax_etd_path(etd)

      # Verify metadata from 'About Me' tab
      expect(page).to have_content 'Johnson, Frodo'
      expect(page).to have_content 'Spring 2018'
      expect(etd.post_graduation_email).to eq ['frodo@example.com']
      expect(page).to have_content 'School Emory College'
      expect(page).to have_content 'Department Religion'
      expect(page).to have_content 'Subfield / Discipline Ethics and Society'
      expect(page).to have_content 'Degree Ph.D.'
      expect(page).to have_content 'Submission Dissertation'
      expect(page).to have_content 'Committee Chair / Thesis Advisor Fred'
      expect(page).to have_content 'Committee Members Barney'
      expect(etd.committee_chair.map(&:affiliation)).to include ["Emory University"]
      expect(etd.committee_members.map(&:affiliation)).to include ['Emory University']

      # Verify metadata from 'My ETD' tab
      expect(page).to have_content title
      expect(page).to have_content 'Language English'
      expect(page).to have_content 'Abstract Literature from the US'
      expect(page).to have_content 'Table of Contents Chapter One'
      expect(page).to have_content 'Research field Aeronomy'
      expect(page).to have_content 'Keyword key1'
      expect(etd.copyright_question_one).to eq 'false'
      expect(etd.copyright_question_two).to eq 'false'
      expect(etd.copyright_question_three).to eq 'false'

      # Verify data from 'My PDF' tab
      # TODO: Test primary PDF
    end
  end

  context 'a logged out user' do
    scenario "cannot get to submit page from 'Submit My ETD' link" do
      visit(root_url)
      click_link("Submit My ETD")

      expect(current_url).not_to start_with new_hyrax_etd_url
      expect(current_url.gsub('?locale=en', '')).to eq(new_user_session_url)
    end

    scenario "cannot browse to submit page" do
      visit(new_hyrax_etd_url)

      expect(page).to have_content("You are not authorized to access this page.")
      expect(current_url).to start_with(new_user_session_url)
    end
  end
end
