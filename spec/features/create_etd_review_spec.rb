require 'rails_helper'
require 'active_fedora/cleaner'
require 'workflow_setup'
include Warden::Test::Helpers

def tinymce_fill_in(id, val)
  # use 'sleep until' if you need wait until the TinyMCE editor instance is ready. This is required for cases
  # where the editor is loaded via XHR.
  # sleep 0.5 until
  page.evaluate_script("tinyMCE.get('#{id}') !== null")

  js = "tinyMCE.get('#{id}').setContent('#{val}')"
  page.execute_script(js)
end

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
      select 'Spring 2018', from: 'Graduation date'
      fill_in 'Post graduation email', with: 'frodo@example.com'
      select("Rollins School of Public Health", from: "School")
      select("Epidemiology", from: "Department")

      select('CDC', from: 'Partnering agency')
      select 'PhD', from: 'Degree'
      select 'Dissertation', from: 'I am submitting my'

      fill_in "Committee Chair/Thesis Advisor", with: "Diane Arbus"
      fill_in "Committee Member", with: "Joan Didion"

      click_on("My ETD")
      fill_in 'Title', with: 'Middlemarch'
      select("French", from: "Language")
      tinymce_fill_in('etd_abstract', 'Literature from the US')
      tinymce_fill_in('etd_table_of_contents', 'Chapter One')
      select 'Aeronomy', from: 'Research Field'
      fill_in 'Keyword', with: "Courtship"
      click_on('about_my_etd_data')

      expect(page).to have_content 'Successfully saved About My Etd'
      expect(page).to have_css 'li#required-my-etd.complete'

      click_on('My PDF')

      expect(page).to have_content('Add Primary PDF...')

      within('#fileupload') do
        page.attach_file('primary_files[]', "#{fixture_path}/miranda/miranda_thesis.pdf")
      end

      expect(page).to have_css('li#required-files.complete')

      click_on('Supplemental Files')

      expect(page).to have_content('Add Supplementary files...')

      page.attach_file('supplemental_files[]', "#{fixture_path}/magic_warrior_cat.jpg")

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

      # About Me and My Program
      expect(page).to have_content("Park, Miranda")
      expect(page).to have_content('frodo@example.com')
      expect(page).to have_content("Rollins School of Public Health")
      expect(page).to have_content('Epidemiology')
      expect(page).to have_content('CDC')
      expect(page).to have_content('Spring 2018')
      expect(page).to have_content('Ph.D.')
      expect(page).to have_content('Dissertation')

      # TODO: committee content
      # expect(page).to have_content('Diane Arbus')
      # expect(page).to have_content('Joan Didion')

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

      # My Embargoes
      expect(page).to have_content('Files and Table of Contents')
      expect(page).to have_content('6 months')

      expect(page).to have_content('Review the information you entered on previous tabs. To edit, use the tabs above to navigate back to that section and correct your information.')
      expect(page).to have_css('#with_files_submit:disabled')
    end

    scenario "Miranda previews, agrees to Emory submission policy and submits her ETD", js: true do
      fill_in 'Student Name', with: 'Park, Miranda'
      select 'Spring 2018', from: 'Graduation date'
      fill_in 'Post graduation email', with: 'frodo@example.com'
      select("Rollins School of Public Health", from: "School")
      select("Epidemiology", from: "Department")

      select('CDC', from: 'Partnering agency')
      select 'PhD', from: 'Degree'
      select 'Dissertation', from: 'I am submitting my'

      fill_in "Committee Chair/Thesis Advisor", with: "Diane Arbus"
      fill_in "Committee Member", with: "Joan Didion"

      click_on("My ETD")
      fill_in 'Title', with: 'Middlemarch'
      select("French", from: "Language")
      tinymce_fill_in('etd_abstract', 'Literature from the US')
      tinymce_fill_in('etd_table_of_contents', 'Chapter One')
      select 'Aeronomy', from: 'Research Field'
      fill_in 'Keyword', with: "Courtship"
      click_on('about_my_etd_data')

      expect(page).to have_content 'Successfully saved About My Etd'
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
    end
  end
end
