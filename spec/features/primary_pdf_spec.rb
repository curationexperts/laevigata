require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Upload a Primary PDF' do
  let(:user) { create :user }
  context 'a logged in user' do
    before do
      login_as user
      visit("/concern/etds/new")
    end

    scenario "Upload the Pdf", js: true do
      click_on('My PDF')
      expect(page).to have_content('Add Primary PDF...')
      expect(page).to have_content('Browse cloud files')
    end
  end
end
