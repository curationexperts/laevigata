require 'rails_helper'
require 'active_fedora/cleaner'
require 'workflow_setup'
include Warden::Test::Helpers

RSpec.feature 'Create an Etd' do
  let(:user) { create :user }

  context 'a logged in (non-admin) user' do
    let(:title) { 'A great thesis by Frodo' }
    let(:workflow_setup) { WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/epidemiology_admin_sets.yml", "/dev/null") }

    before do
      # Don't run background jobs during the spec
      page.driver.console_messages
      allow(ActiveJob::Base).to receive_messages(perform_later: nil, perform_now: nil)

      # Create AdminSet and Workflow
      ActiveFedora::Cleaner.clean!
      workflow_setup.setup

      login_as user
      visit new_hyrax_etd_path
    end

    scenario "Miranda can preview her entire etd", js: true do
      fill_in 'Student Name', with: 'Park, Miranda'
      select 'Spring 2018', from: 'Graduation Date'
      fill_in 'Post Graduation Email', with: 'frodo@example.com'
      select("Rollins School of Public Health", from: "School")
      select("Epidemiology", from: "Department")

      expect(page).to have_select('Partnering Agency')
      select('CDC', from: 'Partnering Agency')
      select 'PhD', from: 'Degree'
      select 'Dissertation', from: 'Submission Type'

      fill_in "etd[committee_chair_attributes][0][name][]", with: "Diane Arbus"
      select 'Non-Emory Committee Member', from: "etd_committee_members_attributes_0_affiliation_type"
      fill_in "etd[committee_members_attributes][0]_affiliation", with: "NASA"
      fill_in "etd[committee_members_attributes][0][name][]", with: "Joan Didion"

      click_on("My ETD")
      fill_in 'Title', with: 'Middlemarch'
      select("French", from: "Language")
      tinymce_fill_in('etd_abstract', 'Literature from the US')
      tinymce_fill_in('etd_table_of_contents', 'Chapter One')
      select 'Aeronomy', from: 'Research Field'
      fill_in 'Keyword', with: "Courtship"
      click_on('about_my_etd_data')

      expect(page).to have_css 'li#required-my-etd.complete'

      click_on('My PDF')

      expect(page).to have_content('Add Primary PDF')

      within('#fileupload') do
        page.attach_file('primary_files[]', "#{fixture_path}/miranda/miranda_thesis.pdf")
      end

      expect(page).to have_css('li#required-files.complete')

      click_on('Supplemental Files')

      expect(page).to have_content('Add Supplementary files...')

      within('#supplemental_fileupload') do
        page.attach_file('supplemental_files[]', "#{fixture_path}/magic_warrior_cat.jpg")
      end

      sleep(5)
      click_on('Add Required Metadata')
      # sleep is not ideal for these collapse and show events but the length of wait time is proving difficult to mandate otherwise
      sleep(10)

      expect(page).to have_css('li#required-supplemental-files.incomplete')

      expect(page).to have_content('File Name')
      expect(page).to have_content('Title')
      expect(page).to have_content('Description')

      fill_in 'etd[supplemental_file_metadata][0]title', with: "Super Great Title"
      fill_in 'etd[supplemental_file_metadata][0]description', with: "Super Great Description"
      select('Sound', from: 'etd[supplemental_file_metadata][0]file_type')

      sleep(10)

      expect(page).to have_css('li#required-supplemental-files.complete')

      click_on("Embargoes")

      expect(page).to have_content('What do you want to embargo?')

      select('Files and Table of Contents', from: 'embargo_type')

      select('Laney Graduate School', from: 'embargo_school')

      select('6 months', from: 'etd_embargo_length')

      expect(page).to have_css('li#required-embargoes.complete')

      expect(page).to have_css('li#required-embargoes.complete')

      click_on('Review')

      expect(page).to have_css('#preview_my_etd')

      find("#preview_my_etd").click

      # About Me
      expect(page).to have_content("Park, Miranda")
      expect(page).to have_content('frodo@example.com')
      expect(page).to have_content("Rollins School of Public Health")
      expect(page).to have_content('Epidemiology')
      expect(page).to have_content('CDC')
      expect(page).to have_content('Spring 2018')
      expect(page).to have_content('Ph.D.')
      expect(page).to have_content('Dissertation')

      expect(page).to have_content('Diane Arbus, Emory')
      expect(page).to have_content('Joan Didion, NASA')

      # About My Etd
      expect(page).to have_content('Middlemarch')
      expect(page).to have_content('French')
      expect(page).to have_content('Literature from the US')
      expect(page).to have_content('Chapter One')
      expect(page).to have_content('Aeronomy')
      expect(page).to have_content('Courtship')

      # My Primary PDF
      expect(page).to have_content('miranda_thesis.pdf')

      # My Supplementary Files
      expect(page).to have_content('magic_warrior_cat.jpg')
      expect(page).to have_content("Super Great Title")
      expect(page).to have_content("Super Great Description")
      expect(page).to have_content("Sound")

      # My Embargoes
      expect(page).to have_content('Files and Table of Contents')
      expect(page).to have_content('6 months')

      expect(page).to have_content('Review the information you entered on previous tabs. To edit, use the tabs above to navigate back to that section and correct your information.')
      expect(page).to have_css('#with_files_submit:disabled')
      logout
    end

    scenario "Miranda previews, agrees to Emory submission policy and submits her ETD", js: true do
      fill_in 'Student Name', with: 'Park, Miranda'
      select 'Spring 2018', from: 'Graduation Date'
      fill_in 'Post Graduation Email', with: 'frodo@example.com'
      select("Rollins School of Public Health", from: "School")
      select("Epidemiology", from: "Department")

      select('CDC', from: 'Partnering Agency')
      select 'PhD', from: 'Degree'
      select 'Dissertation', from: 'Submission Type'

      fill_in "etd[committee_chair_attributes][0][name][]", with: "Diane Arbus"
      fill_in "etd[committee_members_attributes][0][name][]", with: "Joan Didion"

      click_on("My ETD")
      fill_in 'Title', with: 'Middlemarch'
      select("French", from: "Language")
      tinymce_fill_in('etd_abstract', 'Literature from the US')
      tinymce_fill_in('etd_table_of_contents', 'Chapter One')
      select 'Aeronomy', from: 'Research Field'
      fill_in 'Keyword', with: "Courtship"
      click_on('about_my_etd_data')

      expect(page).to have_css 'li#required-my-etd.complete'

      click_on('My PDF')

      within('#fileupload') do
        page.attach_file('primary_files[]', "#{fixture_path}/miranda/miranda_thesis.pdf")
      end

      expect(page).to have_css('li#required-files.complete')

      click_on('Supplemental Files')

      check('etd_no_supplemental_files')

      expect(page).to have_css('li#required-supplemental-files.complete')

      click_on('Embargoes')

      check('no_embargoes')

      expect(page).to have_css('li#required-embargoes.complete')

      click_on('Review')

      expect(page).to have_css('#preview_my_etd')

      find("#preview_my_etd").click

      expect(find("#with_files_submit")).to be_disabled

      check('agreement')

      expect(find("#with_files_submit")).not_to be_disabled

      expect(page).to have_css('li#required-review.complete')

      click_on('Save')

      expect(page).to have_content 'Middlemarch'
      expect(page).to have_content 'Pending approval'
      logout
    end
  end
end
