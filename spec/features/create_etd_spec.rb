# Generated via `rails generate hyrax:work Etd`
require 'rails_helper'

include Warden::Test::Helpers

RSpec.feature 'Create an Etd' do
  let(:user) { create :user }

  context 'a logged in user' do
    before do
      login_as user
      visit("/concern/etds/new")
    end

    scenario "View Etd Tabs", js: true do
      expect(page).to have_selector("[data-toggle='tab']", text: "About Me")
      expect(page).to have_selector("[data-toggle='tab']", text: "My ETD")
      expect(page).to have_selector("[data-toggle='tab']", text: "My PDF")
      expect(page).to have_selector("[data-toggle='tab']", text: "Supplemental Files")
      expect(page).to have_selector("[data-toggle='tab']", text: "Embargoes")
      expect(page).to have_selector("[data-toggle='tab']", text: "Review & Submit")
      # student users have link to dashboard
      expect(page).to have_link("Dashboard")
    end

    scenario "Submission Checklist contains all ETD requirement checkboxes" do
      expect(page).to have_selector("li#required-about-me")
      expect(page).to have_selector("li#required-my-etd")
      expect(page).to have_selector("li#required-files")
      expect(page).to have_selector("li#required-supplemental-files")
      expect(page).to have_selector("li#required-embargoes")
    end
  end

  context 'a logged in (non-admin) user' do
    let(:title) { 'A great thesis by Frodo' }
    let(:workflow_setup) { WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/ec_admin_sets.yml", "/dev/null") }

    before do
      # Don't run background jobs during the spec
      allow(ActiveJob::Base).to receive_messages(perform_later: nil, perform_now: nil)

      # Create AdminSet and Workflow
      ActiveFedora::Cleaner.clean!
      workflow_setup.setup

      login_as user
      visit new_hyrax_etd_path
    end

    scenario "Create a new ETD", js: true do
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
      fill_in 'etd[committee_members_attributes][0]_name', with: 'Barney'

      # Fill in 'My ETD' tab
      click_on('My ETD')
      fill_in 'Title', with: title
      select 'English', from: 'Language'
      tinymce_fill_in('etd_abstract', 'Literature from the US')
      tinymce_fill_in('etd_table_of_contents', 'Chapter One')
      select 'Aeronomy', from: 'Research Field'
      fill_in 'Keyword', with: 'key1'
      find('#question_1').choose('No')
      find('#question_2').choose('No')
      find('#question_3').choose('No')
      click_on('Save My ETD')

      click_on('My PDF')
      page.attach_file('primary_files[]', "#{fixture_path}/miranda/miranda_thesis.pdf")
      expect(page).to have_css('li#required-files.complete')

      # TODO: Attach supplementary file(s)
      click_on('Supplemental Files')
      check 'I have no supplemental files.'

      # TODO: Should we create an embargo in this spec, or is
      # that tested in spec/features/create_etd_embargo_spec.rb?
      click_on('Embargoes')
      check 'I do not want to embargo my thesis or dissertation.'

      # Save the form
      click_on('Review & Submit')
      expect(page).to have_css '#preview_my_etd'
      find(:css, '#preview_my_etd').click
      check('agreement')
      save_and_wait = -> { click_button "Save"; wait_for_ajax(10) }
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
      expect(etd.committee_chair.map(&:affiliation)).to eq [['Emory University']]
      expect(etd.committee_members.map(&:affiliation)).to eq [['Emory University']]

      # Verify metadata from 'My ETD' tab
      expect(page).to have_content title
      expect(page).to have_content 'Language English'
      expect(page).to have_content 'Abstract <p>Literature from the US</p>'
      expect(page).to have_content 'Table of Contents <p>Chapter One</p>'
      expect(page).to have_content 'Research field Aeronomy'
      expect(page).to have_content 'Keyword key1'
      expect(etd.copyright_question_one).to eq 'false'
      expect(etd.copyright_question_two).to eq 'false'
      expect(etd.copyright_question_three).to eq 'false'

      # TODO: Test primary PDF
      # TODO: Test Supplemental files
      # TODO: Test Embargo (if there is one)
    end
  end

  context 'a logged out user' do
    scenario "cannot get to submit page from 'Submit My ETD' link" do
      visit(root_url)
      click_link("Submit My ETD")

      expect(current_url).not_to start_with new_hyrax_etd_url
      expect(current_url).to eq(new_user_session_url)
    end

    scenario "cannot browse to submit page" do
      visit(new_hyrax_etd_url)

      expect(page).to have_content("You are not authorized to access this page.")
      expect(current_url).to start_with(new_user_session_url)
    end
  end
end
