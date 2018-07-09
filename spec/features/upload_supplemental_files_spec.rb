require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Supplemental files', integration: true do
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

      expect(page).not_to have_content('Required Metadata')
      expect(page).not_to have_content('File Name')

      within('#supplemental_fileupload') do
        page.attach_file('supplemental_files[]', "#{fixture_path}/magic_warrior_cat.jpg", visible: false, wait: 10)
      end

      expect(page).to have_content('Required Metadata')
      expect(page).to have_content('File Name')
      expect(page).to have_content('Title')
      expect(page).to have_content('Description')

      expect(page).to have_select('etd[supplemental_file_metadata][0]file_type')
    end

    scenario "Students can't upload duplicate supplemental files", js: true do
      click_on('Supplemental Files')

      within('#supplemental_fileupload') do
        page.attach_file('supplemental_files[]', "#{fixture_path}/magic_warrior_cat.jpg", visible: false, wait: 10)
      end
      wait_for_ajax

      within('#supplemental_fileupload') do
        page.attach_file('supplemental_files[]', "#{fixture_path}/magic_warrior_cat.jpg", visible: false, wait: 10)
      end
      wait_for_ajax
      expect(page).to have_content('Duplicate found. This file has already been uploaded.')
    end

    scenario "checking 'no files' after uploading a few and entering metadata hides the files and metadata form", js: true do
      click_on('Supplemental Files')

      within('#supplemental_fileupload') do
        page.attach_file('supplemental_files[]', "#{fixture_path}/magic_warrior_cat.jpg", visible: false, wait: 10)
      end

      expect(page).to have_content('magic_warrior_cat.jpg')
      expect(page).to have_css('#supplemental_files_metadata tbody tr', count: 1)

      check('etd_no_supplemental_files')

      expect(page).not_to have_content('magic_warrior_cat.jpg')
      expect(page).to have_css('#supplemental_files_metadata tbody tr', count: 0)
    end

    scenario "deleting a file removes its metadata content", js: true do
      # if you upload two files and delete one, expect show metadata link and table to remain, but row with deleted file gone
      click_on('Supplemental Files')

      within('#supplemental_fileupload') do
        page.attach_file('supplemental_files[]', "#{fixture_path}/magic_warrior_cat.jpg", visible: false, wait: 10)
      end
      expect(page).to have_select('etd[supplemental_file_metadata][0]file_type')

      within('#supplemental_fileupload') do
        page.attach_file('supplemental_files[]', "#{fixture_path}/nasa.jpeg", visible: false, wait: 10)
      end
      expect(page).to have_select('etd[supplemental_file_metadata][1]file_type')

      find('button.delete', match: :first).click
      expect(page).not_to have_select('etd[supplemental_file_metadata][0]file_type')
      expect(page).to     have_select('etd[supplemental_file_metadata][1]file_type')

      expect(page).to have_content('File Name')
      expect(page).to have_content('Title')
      expect(page).to have_content('Description')
      expect(page).to have_content('File Type')

      expect(page).not_to have_content('magic_warrior_cat.jpg')
      expect(page).to     have_content('nasa.jpeg')
    end

    scenario "deleting all files removes all metadata content", js: true do
      # if you upload two files and delete them both, expect show metadata link and metadata not to be there
      click_on('Supplemental Files')
      expect(page).to have_content('Add Supplemental Files')

      within('#supplemental_fileupload') do
        page.attach_file('supplemental_files[]', "#{fixture_path}/magic_warrior_cat.jpg", visible: false, wait: 10)
      end
      expect(page).to have_select('etd[supplemental_file_metadata][0]file_type')

      within('#supplemental_fileupload') do
        page.attach_file('supplemental_files[]', "#{fixture_path}/nasa.jpeg", visible: false, wait: 10)
      end
      expect(page).to have_select('etd[supplemental_file_metadata][1]file_type')

      find('button.delete', match: :first).click

      # Metadata fields for the first file have been removed
      expect(page).not_to have_select('etd[supplemental_file_metadata][0]file_type')
      expect(page).to     have_select('etd[supplemental_file_metadata][1]file_type')

      # First file has been removed
      expect(page).not_to have_content('magic_warrior_cat.jpg')
      expect(page).to     have_content('nasa.jpeg')

      find('button.delete').click

      # Metadata table has no rows left
      expect(page).to     have_css('#supplemental_files_metadata tbody')
      expect(page).not_to have_css('#supplemental_files_metadata tbody tr')
      expect(page).not_to have_content('nasa.jpeg')
      expect(page).not_to have_select('etd[supplemental_file_metadata][1]file_type')
    end
  end
end
