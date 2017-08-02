require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Supplemental files' do
  let(:user) { create :user }
  context 'logged in user uploads Supplemental files' do
    before do
      page.driver.console_messages # need capybara confg debug = true also to see them
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

      page.attach_file('supplemental_files[]', "#{fixture_path}/magic_warrior_cat.jpg")

      expect(page).to have_link('Show Additional Metadata')

      click_on('Show Additional Metadata')

      expect(page).to have_content('File Name')
      expect(page).to have_link('Hide Additional Metadata')

      click_link('Hide Additional Metadata')
      
      # expect will wait for dom to finish up
      expect(page).to have_content('magic_warrior_cat.jpg')

      # why doesn't this js collapse event occur?
      # the first one does
      expect(page).not_to have_content('File Name')
      expect(page).to have_link('Show Additional Metadata')
    end
  end
end
