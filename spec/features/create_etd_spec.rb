# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'

include Warden::Test::Helpers

RSpec.feature 'Create an Etd' do
  let(:user) { create :user }

  context 'a logged in user' do
    before do
      login_as user
    end

    scenario "View Etd Tabs", js: true do
      visit("/concern/etds/new")
      expect(page).to have_selector("[data-toggle='tab']", text: "About Me")
      expect(page).to have_selector("[data-toggle='tab']", text: "About My ETD")
      expect(page).to have_selector("[data-toggle='tab']", text: "My PDF")
      expect(page).to have_selector("[data-toggle='tab']", text: "My Supplemental Files")
      expect(page).to have_selector("[data-toggle='tab']", text: "My Embargoes")
      expect(page).to have_selector("[data-toggle='tab']", text: "Review")
    end

    scenario "view and save 'about me and my program' data", js: true do
      visit("/concern/etds/new")
      # expect(current_path).to include(new_hyrax_etd_url)
      expect(page).to have_css('input#etd_creator')
      expect(page).to have_css('input#etd_title')
      expect(page).to have_css('select#etd_graduation_date')
      expect(page).to have_css('input#etd_post_graduation_email')
      expect(page).to have_css('input#etd_school')
      expect(page).to have_css('input#etd_degree')
      expect(page).to have_css('select#etd_submitting_type')
      expect(page).to have_css('select#etd_research_field')
      expect(page).to have_css('select#etd_committee_chair')
      expect(page).to have_css('select#etd_committee_members')
      expect(page).to have_css('select#etd_partnering_agency')
      fill_in 'Student Name', with: 'Eun, Dongwon'
      # Department is not required, by default it is hidden as an additional field
      fill_in 'Title', with: "A Good Title"
      fill_in "School", with: "Emory College of Arts and Sciences"
      fill_in "Department", with: "Department of Russian and East Asian Languages and Cultures"
      select('Alternative Medicine', from: 'Research Field')
      # select('All rights reserved', from: 'Rights')
      # fill_in 'Keyword', with: 'Surrealism'
      fill_in "Degree", with: "Bachelor of Arts with Honors"
      select("Honors Thesis", from: "I am submitting")
      select('CDC', from: 'Partnering agency')

      click_on('Save About Me')

      expect(page).to have_content 'Successfully saved About: Eun, Dongwon, A Good Title'
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
