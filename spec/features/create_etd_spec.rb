# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'

include Warden::Test::Helpers

RSpec.feature 'Create an Etd' do
  let(:user) { create :user }

  context 'a logged in user' do
    before do
      login_as user
      visit("/concern/etds/new")
    end

    scenario "View Etd Tabs", js: true do
      expect(page).to have_selector("[data-toggle='tab']", text: "About Me")
      expect(page).to have_selector("[data-toggle='tab']", text: "About My ETD")
      expect(page).to have_selector("[data-toggle='tab']", text: "My PDF")
      expect(page).to have_selector("[data-toggle='tab']", text: "My Supplemental Files")
      expect(page).to have_selector("[data-toggle='tab']", text: "My Embargoes")
      expect(page).to have_selector("[data-toggle='tab']", text: "Review")
    end

    scenario "Submission Checklist contains all ETD requirement checkboxes" do
      expect(page).to have_selector("li#required-about-me")
      expect(page).to have_selector("li#required-my-etd")
      expect(page).to have_selector("li#required-files")
      expect(page).to have_selector("li#required-supplemental-files")
      expect(page).to have_selector("li#required-embargoes")
      expect(page).to have_selector("li#required-review")
    end

    scenario "Submit an ETD after saving data in the tabs", js: true do
      click_on('Save About Me')
      click_on('About My ETD')
      fill_in 'Title', with: 'A great thesis'
      click_on('Save My ETD')
      check('agreement')

      click_on('Save')

      expect(page).to have_content("Pending approval")
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
