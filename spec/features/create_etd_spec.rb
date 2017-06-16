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

    scenario "'about me and my program' has all its inputs" do
      # expect(current_path).to include(new_hyrax_etd_url)
      expect(page).to have_css('input#etd_creator')
      expect(page).to have_css('input#etd_title')
      expect(page).to have_css('select#etd_graduation_date')
      expect(page).to have_css('input#etd_post_graduation_email')
      expect(page).to have_css('select#etd_school')
      expect(page).to have_css('select#etd_degree')
      expect(page).to have_css('select#etd_department')
      expect(page).to have_css('select#etd_subfield')
      expect(page).to have_css('select#etd_submitting_type')
      expect(page).to have_css('select#etd_research_field')
      expect(page).to have_css('select#etd_committee_chair_affiliation_type')
      expect(page).to have_css('input#etd_committee_chair_name')
      expect(page).to have_css('select#etd_committee_member_affiliation_type')
      expect(page).to have_css('input#etd_committee_member_name')
      expect(page).to have_css('select#etd_partnering_agency')
    end

    scenario "can save 'about me and my program'", js: true do
      fill_in 'Student Name', with: 'Eun, Dongwon'
      select("Spring 2018", from: "Graduation date")
      fill_in "Post graduation email", with: "graduate@done.com"
      fill_in 'Title', with: "A Good Title"
      select("Laney Graduate School", from: "School")
      select("Religion", from: "Department")
      select("Ethics and Society", from: "Sub Field")
      select('Medicine', from: 'Research Field')
      select('MS', from: "Degree")
      select("Honors Thesis", from: "I am submitting my")
      fill_in "Committee Chair/Thesis Advisor", with: "Diane Arbus"
      fill_in "Committee Member", with: "Joan Didion"

      click_on('Save About Me')

      expect(page).to have_content 'Successfully saved About: Eun, Dongwon, A Good Title'
      expect(page).to have_css('li#required-about-me.complete')
      expect(page).not_to have_css('li#required-about-me.incomplete')
    end

    scenario "'about me requires Parterning Agency for Rollins School'", js: true do
      fill_in 'Student Name', with: 'Eun, Dongwon'
      select("Spring 2018", from: "Graduation date")
      fill_in "Post graduation email", with: "graduate@done.com"
      fill_in 'Title', with: "A Good Title"
      select("Rollins School of Public Health", from: "School")
      select("Biostatistics", from: "Department")

      select('Medicine', from: 'Research Field')
      select('MS', from: "Degree")
      select("Honors Thesis", from: "I am submitting my")
      fill_in "Committee Chair/Thesis Advisor", with: "Diane Arbus"
      fill_in "Committee Member", with: "Joan Didion"

      expect(page).not_to have_css('li#required-about-me.complete')
      expect(page).to have_css('li#required-about-me.incomplete')

      select('CDC', from: 'Partnering agency')

      expect(page).to have_css('li#required-about-me.complete')
      expect(page).not_to have_css('li#required-about-me.incomplete')
    end

    scenario "'about me' has no committee affiliation field when affiliation type Emory Faculty is selected", js: true do
      select('Non-Emory Faculty', from: 'etd_committee_chair_affiliation_type')
      wait_for_ajax
      expect(find("#etd_committee_chair_affiliation")).not_to be_disabled

      select('Emory Faculty', from: 'etd_committee_chair_affiliation_type')
      wait_for_ajax
      expect(find("#etd_committee_chair_affiliation")).to be_disabled
    end

    scenario "'about me' committee affiliation accepts user input when Non-Emory Faculty is selected", js: true do
      select('Non-Emory Faculty', from: 'etd_committee_member_affiliation_type')
      wait_for_ajax
      fill_in "etd_committee_member_affiliation", with: "MOMA"
      expect(find_field("etd_committee_member_affiliation").value).to eq("MOMA")
    end

    scenario "'about me and my program' requires non-emory committee member affiliation", js: true do
      fill_in 'Student Name', with: 'Eun, Dongwon'
      select("Spring 2018", from: "Graduation date")
      fill_in "Post graduation email", with: "graduate@done.com"
      fill_in 'Title', with: "A Good Title"
      select("Laney Graduate School", from: "School")
      select("Religion", from: "Department")
      select("Ethics and Society", from: "Sub Field")
      select('Medicine', from: 'Research Field')
      select('MS', from: "Degree")

      select("Honors Thesis", from: "I am submitting my")

      select('CDC', from: 'Partnering agency')

      fill_in "Committee Chair/Thesis Advisor", with: "Diane Arbus"

      select('Non-Emory Faculty', from: 'etd_committee_chair_affiliation_type')

      select('Emory Faculty', from: 'etd_committee_member_affiliation_type')
      fill_in "Committee Member", with: "Joan Didion"

      click_on('Save About Me')

      expect(page).to have_content 'Successfully saved About: Eun, Dongwon, A Good Title'
      expect(page).to have_css('li#required-about-me.complete')
      expect(page).not_to have_css('li#required-about-me.incomplete')
    end

    scenario "display indicates incomplete 'about me and my program' data", js: true do
      visit("/concern/etds/new")
      select('Emory Faculty', from: 'etd_committee_chair_affiliation_type')
      fill_in "Committee Chair/Thesis Advisor", with: "Diane Arbus"
      select('Non-Emory Faculty', from: 'etd_committee_member_affiliation_type')
      fill_in "Committee Member", with: "Joan Didion"
      select('CDC', from: 'Partnering agency')
      click_on('Save About Me')

      expect(page).to have_css('li#required-about-me.incomplete')
      expect(page).not_to have_css('li#required-about-me.complete')
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
