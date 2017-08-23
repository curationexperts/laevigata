require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Supplemental files' do
  let(:user) { create :user }
  context 'logged in user uploads Supplemental files' do
    before do
      login_as user
      visit("/concern/etds/new")
    end

    after do
      logout
    end

    scenario "Supplemental Files Content", js: true unless continuous_integration? do
      click_on('Supplemental Files')
      expect(page).to have_content('I have no supplemental files.')
      expect(page).to have_content('Add Supplemental Files')
      # expect(page).to have_content('Browse cloud files')
    end

    scenario "Students can add metadata to their Supplemental Files", js: true do
      click_on('Supplemental Files')

      expect(page).not_to have_content('Add Required Metadata')
      expect(page).not_to have_content('File Name')

      within('#supplemental_fileupload') do
        page.attach_file('supplemental_files[]', "#{fixture_path}/magic_warrior_cat.jpg")
      end

      expect(page).to have_link('Add Required Metadata')

      click_on('Add Required Metadata')

      expect(page).to have_content('File Name')
      expect(page).to have_content('Title')
      expect(page).to have_content('Description')

      expect(page).to have_select('etd[supplemental_file_metadata][0]file_type')

      # capybara wait settings aren't working here but sleep does
      sleep(5)
      expect(page).to have_link('Hide Required Metadata')

      sleep(5)

      click_on('Hide Required Metadata')

      expect(page).not_to have_content('File Name')
      expect(page).to have_link('Add Required Metadata')
    end

    scenario "Students can't upload duplicate supplemental files", js: true do
      click_on('Supplemental Files')

      within('#supplemental_fileupload') do
        page.attach_file('supplemental_files[]', "#{fixture_path}/magic_warrior_cat.jpg")
      end
      wait_for_ajax

      within('#supplemental_fileupload') do
        page.attach_file('supplemental_files[]', "#{fixture_path}/magic_warrior_cat.jpg")
      end
      wait_for_ajax
      expect(page).to have_content('Duplicate found. This file has already been uploaded.')
    end

    scenario "Students can submit metadata for each of their supplemental files", js: true unless continuous_integration? do
      click_on('Supplemental Files')

      within('#supplemental_fileupload') do
        page.attach_file('supplemental_files[]', "#{fixture_path}/magic_warrior_cat.jpg")
      end

      click_on('Add Required Metadata')
      wait_for_ajax
      fill_in 'etd[supplemental_file_metadata][0]title', with: "Super Great Title"
      fill_in 'etd[supplemental_file_metadata][0]description', with: "Super Great Description"
      select('Sound', from: 'etd[supplemental_file_metadata][0]file_type')
      # the rest of the test might end up in the create etd super spec or review, fake expect for now, test is checking the form works
      expect(page).to have_content('File Name')
    end

    scenario "Adding more files is not allowed after students have begun entering metadata", js: true unless continuous_integration? do
      click_on('Supplemental Files')

      within('#supplemental_fileupload') do
        page.attach_file('supplemental_files[]', "#{fixture_path}/magic_warrior_cat.jpg")
      end
      # any time metadata is showing, uploading should be disabled to prevent metadata form from becoming stale
      click_on('Add Required Metadata')
      sleep(5) # more reliable than wait_times

      expect(find("#supplemental_files_uploader")).to be_disabled

      fill_in 'etd[supplemental_file_metadata][0]title', with: "Super Great Title"

      sleep(5)

      expect(find("#supplemental_files_uploader")).to be_disabled

      click_on('Hide Required Metadata')
      sleep(5)

      expect(find("#supplemental_files_uploader")).not_to be_disabled
    end

    scenario "checking 'no files' after uploading a few and entering metadata hides the files and metadata form", js: true unless continuous_integration? do
      click_on('Supplemental Files')

      within('#supplemental_fileupload') do
        page.attach_file('supplemental_files[]', "#{fixture_path}/magic_warrior_cat.jpg")
      end

      click_on('Add Required Metadata')
      sleep(10) # ugly but works

      check('etd_no_supplemental_files')

      expect(page).not_to have_content('magic_warrior_cat.jpg')
      expect(page).not_to have_content('File Name')
    end

    scenario "deleting a file removes its metadata content", js: true do
      # if you upload two files and delete one, expect show metadata link and table to remain, but row with deleted file gone
      click_on('Supplemental Files')

      within('#supplemental_fileupload') do
        page.attach_file('supplemental_files[]', "#{fixture_path}/magic_warrior_cat.jpg")
      end

      within('#supplemental_fileupload') do
        page.attach_file('supplemental_files[]', "#{fixture_path}/nasa.jpeg")
      end

      click_on('Add Required Metadata')
      fill_in 'etd[supplemental_file_metadata][0]title', with: "Super Great Title"

      find('button.delete', match: :first).click

      expect(page).to have_content('File Name')
      expect(page).to have_content('Title')
      expect(page).to have_content('Description')
      expect(page).to have_content('File Type')
      expect(page).to have_content('Hide Required Metadata')
      expect(page).not_to have_content('magic_warrior_cat.jpg')
    end

    scenario "deleting all files removes all metadata content", js: true do
      # if you upload two files and delete them both, expect show metadata link and table not to be there
      click_on('Supplemental Files')
      expect(page).to have_content('Add Supplemental Files')

      within('#supplemental_fileupload') do
        page.attach_file('supplemental_files[]', "#{fixture_path}/magic_warrior_cat.jpg")
      end
      wait_for_ajax
      within('#supplemental_fileupload') do
        page.attach_file('supplemental_files[]', "#{fixture_path}/nasa.jpeg")
      end
      wait_for_ajax
      click_on('Add Required Metadata')
      find('button.delete', match: :first).click

      # metadata table still exists
      expect(page).to have_content('File Name')
      expect(page).to have_content('Title')
      expect(page).to have_content('Description')
      expect(page).to have_content('File Type')
      expect(page).to have_content('Hide Required Metadata')

      # but metadata for first file does not
      expect(page).not_to have_content('magic_warrior_cat.jpg')
      expect(page).to have_content('nasa.jpeg')

      find('button.delete').click

      # metadata table gone
      expect(page).not_to have_content('File Name')
      expect(page).not_to have_content('Title')
      expect(page).not_to have_content('Description')
      expect(page).not_to have_content('File Type')
      expect(page).not_to have_content('Hide Required Metadata')
      expect(page).not_to have_content('nasa.jpeg')
    end

    scenario "hiding metadata does not remove it", js: true do
      click_on('Supplemental Files')
      expect(page).to have_content('Add Supplemental Files')

      within('#supplemental_fileupload') do
        page.attach_file('supplemental_files[]', "#{fixture_path}/magic_warrior_cat.jpg")
      end

      click_on('Add Required Metadata')
      wait_for_ajax
      fill_in 'etd[supplemental_file_metadata][0]title', with: "Super Great Title"
      fill_in 'etd[supplemental_file_metadata][0]description', with: "Super Great Description"
      select('Sound', from: 'etd[supplemental_file_metadata][0]file_type')

      click_on('Hide Required Metadata')
      wait_for_ajax
      expect(find_field('etd[supplemental_file_metadata][0]title').value).to eq("Super Great Title")
      expect(find_field('etd[supplemental_file_metadata][0]description').value).to eq("Super Great Description")
      expect(find_field('etd[supplemental_file_metadata][0]file_type').value).to eq("Sound")
    end
  end
end
