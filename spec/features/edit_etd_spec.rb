# Generated via `rails generate hyrax:work Etd`
require 'rails_helper'

include Warden::Test::Helpers

RSpec.feature 'Edit an Etd' do
  # using an admin in this test because they will see the edit button in the show view and be allowed to edit
  let(:admin_superuser) { User.where(uid: "tezprox").first }

  context 'a logged in admin_superuser' do
    let(:title) { 'Another great thesis by Frodo' }
    let(:workflow_setup) { WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/ec_admin_sets.yml", "/dev/null") }

    before do
      # Don't run background jobs during the spec
      allow(ActiveJob::Base).to receive_messages(perform_later: nil, perform_now: nil)

      # Create AdminSet and Workflow
      ActiveFedora::Cleaner.clean!
      workflow_setup.setup

      login_as admin_superuser
      visit new_hyrax_etd_path
    end

    scenario "Edit a new ETD's department and sub field", js: true do
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
      fill_in 'etd[committee_members_attributes][0]_name', with: 'Barney'

      # Fill in 'My ETD' tab
      click_on('My ETD')
      fill_in 'Title', with: title
      select 'English', from: 'Language'
      tinymce_fill_in('etd_abstract', 'Literature from the US')
      tinymce_fill_in('etd_table_of_contents', 'Chapter One')
      expect(page).to have_css('li#required-my-etd.incomplete')

      select 'Aeronomy', from: 'Research Field'
      fill_in 'Keyword', with: 'key1'
      expect(page).to have_css('li#required-my-etd.incomplete')

      find('#question_1').choose('No')
      find('#question_2').choose('No')
      find('#question_3').choose('No')

      click_on('about_my_etd_data')
      wait_for_ajax(15)

      expect(page).to have_css 'li#required-my-etd.complete'
      click_on('My PDF')

      page.attach_file('primary_files[]', "#{fixture_path}/miranda/miranda_thesis.pdf")
      expect(page).to have_css('li#required-files.complete')

      click_on('Supplemental Files')
      check 'I have no supplemental files.'
      sleep(5)

      click_on('Embargoes')
      check 'I do not want to embargo my thesis or dissertation.'
      sleep(10)
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

      # TODO: There is a bug that doesn't allow a student to
      # view their own ETD until after their graduation date.
      # After that bug is fixed, remove this code that sets
      # the degree_awarded date.
      # https://github.com/curationexperts/laevigata/issues/575
      etd.degree_awarded = Date.parse("17-05-17").strftime("%d %B %Y")
      etd.state = Vocab::FedoraResourceStatus.active
      etd.save!

      # The admin/student views his ETD
      visit hyrax_etd_path(etd)

      # Verify metadata from 'About Me' tab
      expect(page).to have_content 'Johnson, Frodo'
      expect(page).to have_content 'Spring 2018'

      click_on('Edit')

      # Verify correct Department and Sub Fields are selected and not disabled
      expect(find('#etd_department').value).to eq 'Religion'
      expect(find('#etd_subfield').value).to eq 'Ethics and Society'
      expect(find('#etd_department')).not_to be_disabled
      expect(find('#etd_subfield')).not_to be_disabled
    end
    scenario "Edit a new ETD's department", js: true do
      # expect 'About Me' department and subfield to be disabled, as they are dynamically supplied by student's school choice
      expect(find('#etd_department')).to be_disabled
      expect(find('#etd_subfield')).to be_disabled

      # Fill in 'About Me' tab
      fill_in 'Student Name', with: 'Johnson, Frodo'
      select 'Spring 2018', from: 'Graduation Date'
      fill_in 'Post Graduation Email', with: 'frodo@example.com'
      select 'Emory College', from: 'School'
      select 'African American Studies', from: 'Department'
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
      expect(page).to have_css('li#required-my-etd.incomplete')

      select 'Aeronomy', from: 'Research Field'
      fill_in 'Keyword', with: 'key1'
      expect(page).to have_css('li#required-my-etd.incomplete')

      find('#question_1').choose('No')
      find('#question_2').choose('No')
      find('#question_3').choose('No')

      click_on('about_my_etd_data')
      wait_for_ajax(15)

      expect(page).to have_css 'li#required-my-etd.complete'
      click_on('My PDF')

      page.attach_file('primary_files[]', "#{fixture_path}/miranda/miranda_thesis.pdf")
      expect(page).to have_css('li#required-files.complete')

      click_on('Supplemental Files')
      check 'I have no supplemental files.'
      sleep(5)

      click_on('Embargoes')
      check 'I do not want to embargo my thesis or dissertation.'
      sleep(10)
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

      # TODO: There is a bug that doesn't allow a student to
      # view their own ETD until after their graduation date.
      # After that bug is fixed, remove this code that sets
      # the degree_awarded date.
      # https://github.com/curationexperts/laevigata/issues/575
      etd.degree_awarded = Date.parse("17-05-17").strftime("%d %B %Y")
      etd.state = Vocab::FedoraResourceStatus.active
      etd.save!

      # The admin/student views his ETD
      visit hyrax_etd_path(etd)

      # Verify metadata from 'About Me' tab
      expect(page).to have_content 'Johnson, Frodo'
      expect(page).to have_content 'Spring 2018'

      click_on('Edit')

      # Verify correct Department is selected and not disabled, Sub Fields is disabled
      expect(find('#etd_department').value).to eq 'African American Studies'
      expect(find('#etd_department')).not_to be_disabled
      expect(find('#etd_subfield')).to be_disabled
    end
  end
end
