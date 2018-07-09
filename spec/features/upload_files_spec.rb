require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Primary PDF', integration: true do
  let(:user) { create :user }
  context 'a logged in user uploads Primary PDF' do
    before do
      login_as user
      visit("/concern/etds/new")
    end

    after do
      logout
    end

    scenario "Primary Pdf requires pdf format", js: true unless continuous_integration? do
      click_on('My PDF')
      expect(page).to have_content('Add Primary PDF')

      within('#fileupload') do
        page.attach_file('primary_files[]', "#{fixture_path}/magic_warrior_cat.jpg", visible: false, wait: 10)
      end

      expect(page).to have_content('The primary file must be in the PDF format.')
      expect(page).to have_css('li#required-files.incomplete')

      within('#fileupload') do
        page.attach_file('primary_files[]', "#{fixture_path}/miranda/miranda_thesis.pdf", visible: false, wait: 10)
      end

      expect(page).not_to have_content('The Primary PDF must be a file in the .pdf format.')
      expect(page).to have_css('li#required-files.complete')
    end
  end
end
