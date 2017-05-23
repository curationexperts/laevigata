# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Create a Etd' do
  let(:user) { create :user }
  context 'a logged in user' do
    before do
      login_as user
    end

    scenario "Submit a basic MS Word Thesis" do
      visit(root_url)
      click_link("Share Your Work")
      expect(current_url).to start_with new_hyrax_etd_url
      expect(page).to have_css('input#etd_title.required')
      expect(page).not_to have_css('input#etd_title.multi_value')
      expect(page).to have_css('input#etd_creator.required')
      expect(page).not_to have_css('input#etd_creator.multi_value')
      fill_in 'Title', with: 'China and its Minority Population'
      fill_in 'Creator', with: 'Eun, Dongwon'
      fill_in 'Keyword', with: 'China'
      # Department is not required, by default it is hidden as an additional field
      click_link("Additional fields")
      fill_in "Department", with: "Department of Russian and East Asian Languages and Cultures"
      fill_in "School", with: "Emory College of Arts and Sciences"
      fill_in "Degree", with: "Bachelor of Arts with Honors"
      select('All rights reserved', from: 'Rights')
      choose('open')
      check('agreement')
      click_on('Files')
      attach_file('files[]', "#{fixture_path}/emory_7tjfb-FILE")
      click_on('Save')
      expect(page).to have_content 'Your files are being processed'
      expect(page).to have_content 'Deposited'
      expect(page).to have_content 'China and its Minority Population'
    end
  end

  context 'a logged out user' do
    scenario "cannot get to submit page from 'share your work' link" do
      visit(root_url)
      click_link("Share Your Work")

      expect(current_url).not_to start_with new_hyrax_etd_url
      expect(current_url).to eq(new_user_session_url)
    end

    scenario "cannot browse to submit page" do
      visit(new_hyrax_etd_url)

      expect(page).to have_content("You are not authorized to access this page.")
      expect(current_url).to start_with(new_user_session_url)
    end
  end
end
