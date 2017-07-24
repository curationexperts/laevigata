require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Upload Files' do
  let(:user) { create :user }
  context 'a logged in user' do
    before do
      login_as user
      visit("/concern/etds/new")
    end

    scenario "Primary Pdf", js: true do
      click_on('My PDF')
      expect(page).to have_content('Add Primary PDF...')
      # expect(page).to have_content('Browse cloud files')
    end

    scenario "Supplemental Files", js: true do
      click_on('My Supplemental Files')
      expect(page).to have_content('I have no supplemental files.')
      expect(page).to have_content('Add Supplementary files...')
      # expect(page).to have_content('Browse cloud files')
    end
  end
end
