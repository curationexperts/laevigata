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

    scenario "Supplemental Files Content", js: true do
      click_on('Supplemental Files')
      expect(page).to have_content('I have no supplemental files.')
      expect(page).to have_content('Add Supplementary files...')
      # expect(page).to have_content('Browse cloud files')
    end

    scenario "Students can add metadata to their Supplemental Files", js: true do
      click_on('Supplemental Files')

      expect(page).not_to have_content('Show Additional Metadata')
      expect(page).not_to have_content('File Name')

      within('#supplemental_fileupload') do
        page.attach_file('supplemental_files[]', "#{fixture_path}/magic_warrior_cat.jpg")
      end

      expect(page).to have_link('Show Additional Metadata')

      click_on('Show Additional Metadata')

      expect(page).to have_content('File Name')
      expect(page).to have_content('Title')
      expect(page).to have_content('Description')

      expect(page).to have_select('supplemental_file_file_type', options: ['Text', 'Dataset', 'Video', 'Image', 'Sound', 'Software'])

      # capybara wait settings aren't working here but sleep does
      sleep(5)
      expect(page).to have_link('Hide Additional Metadata')

      sleep(5)

      click_on('Hide Additional Metadata')

      expect(page).not_to have_content('File Name')
      expect(page).to have_link('Show Additional Metadata')
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

    scenario "Students can submit metadata for each of their supplemental files", js: true do
      click_on('Supplemental Files')

      within('#supplemental_fileupload') do
        page.attach_file('supplemental_files[]', "#{fixture_path}/magic_warrior_cat.jpg")
      end

      click_on('Show Additional Metadata')
      wait_for_ajax
      fill_in :supplemental_file_title, with: "Super Great Title"
      fill_in :supplemental_file_description, with: "Super Great Description"
      select('Sound', from: 'supplemental_file_file_type')
      # the rest of the test might end up in the create etd super spec or review, fake expect for now, test is checking the form works
      expect(page).to have_content('File Name')
    end

    scenario "Adding more files is not allowed after students have begun entering metadata", js: true do
      click_on('Supplemental Files')

      within('#supplemental_fileupload') do
        page.attach_file('supplemental_files[]', "#{fixture_path}/magic_warrior_cat.jpg")
      end

      click_on('Show Additional Metadata')
      wait_for_ajax

      expect(find("#supplemental_files_uploader")).to be_disabled
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

      click_on('Show Additional Metadata')
      fill_in(:supplemental_file_title, with: "Super Great Title", match: :first)

      find('button.delete', match: :first).click

      expect(page).to have_content('File Name')
      expect(page).to have_content('Title')
      expect(page).to have_content('Description')
      expect(page).to have_content('File Type')
      expect(page).to have_content('Hide Additional Metadata')
      expect(page).not_to have_content('magic_warrior_cat.jpg')
    end

    scenario "deleting all files removes all metadata content", js: true do
      # if you upload two files and delete them both, expect show metadata link and table not to be there
      click_on('Supplemental Files')
      expect(page).to have_content('Add Supplementary files...')

      within('#supplemental_fileupload') do
        page.attach_file('supplemental_files[]', "#{fixture_path}/magic_warrior_cat.jpg")
      end
      wait_for_ajax
      within('#supplemental_fileupload') do
        page.attach_file('supplemental_files[]', "#{fixture_path}/nasa.jpeg")
      end
      wait_for_ajax
      click_on('Show Additional Metadata')
      find('button.delete', match: :first).click

      # metadata table still exists
      expect(page).to have_content('File Name')
      expect(page).to have_content('Title')
      expect(page).to have_content('Description')
      expect(page).to have_content('File Type')
      expect(page).to have_content('Hide Additional Metadata')

      # but metadata for first file does not
      expect(page).not_to have_content('magic_warrior_cat.jpg')
      expect(page).to have_content('nasa.jpeg')

      find('button.delete').click

      # metadata table gone
      expect(page).not_to have_content('File Name')
      expect(page).not_to have_content('Title')
      expect(page).not_to have_content('Description')
      expect(page).not_to have_content('File Type')
      expect(page).not_to have_content('Hide Additional Metadata')
      expect(page).not_to have_content('nasa.jpeg')
    end
  end
end
