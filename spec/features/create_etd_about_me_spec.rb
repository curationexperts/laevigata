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

    scenario "'about me and my program' has all its inputs" do
      # expect(current_path).to include(new_hyrax_etd_url)
      expect(page).to have_css('#about_me input#etd_creator')
      expect(page).to have_css('#about_me select#etd_graduation_date')
      expect(page).to have_css('#about_me input#etd_post_graduation_email')
      expect(page).to have_css('#about_me select#etd_school')
      expect(page).to have_css('#about_me select#etd_degree')
      expect(page).to have_css('#about_me select#etd_department')
      expect(page).to have_css('#about_me select#etd_subfield')
      expect(page).to have_css('#about_me select#etd_submitting_type')
      expect(page).to have_css('#about_me select#etd_committee_chair_0_affiliation_type')
      expect(page).to have_css('#about_me input#etd_committee_chair_0_chair_name')
      expect(page).to have_css('#about_me select#etd_committee_members_0_affiliation_type')
      expect(page).to have_css('#about_me input#etd_committee_members_0_name')
      expect(page).to have_css('#about_me select#etd_partnering_agency')
    end

    scenario "can save 'about me and my program'", js: true do
      fill_in 'Student Name', with: 'Eun, Dongwon'
      select("Spring 2018", from: "Graduation date")
      fill_in "Post graduation email", with: "graduate@done.com"
      select("Laney Graduate School", from: "School")
      select("Religion", from: "Department")
      select("Ethics and Society", from: "Sub Field")
      select('MS', from: "Degree")
      select("Honors Thesis", from: "I am submitting my")
      fill_in "Committee Chair/Thesis Advisor", with: "Diane Arbus"
      fill_in "Committee Member", with: "Joan Didion"

      click_on('Save About Me')

      expect(page).to have_content 'Successfully saved About:'

      expect(page).to have_css('li#required-about-me.complete')
      expect(page).not_to have_css('li#required-about-me.incomplete')
    end

    scenario "'about me' has no committee affiliation field when affiliation type Emory is selected", js: true do
      select('Non-Emory Committee Chair', from: 'etd_committee_chair_0_affiliation_type')
      wait_for_ajax
      expect(find("#etd_committee_chair_0_affiliation")).not_to be_disabled

      select('Emory Committee Chair', from: 'etd_committee_chair_0_affiliation_type')
      wait_for_ajax
      expect(find("#etd_committee_chair_0_affiliation")).to be_disabled
    end

    scenario "'about me' committee affiliation accepts user input when Non-Emory is selected", js: true do
      select('Non-Emory Committee Member', from: 'etd_committee_members_0_affiliation_type')
      wait_for_ajax
      fill_in "etd_committee_members_0_affiliation", with: "MOMA"
      expect(find_field("etd_committee_members_0_affiliation").value).to eq("MOMA")
    end

    scenario "'about me' required committee members field", js: true do
      select("Laney Graduate School", from: "School")
      wait_for_ajax
      expect(page).to have_css('#help-members')
      expect(page).to have_css('input#etd_committee_members_0_name.required')
      expect(page).to have_css('div.etd_committee_members_0_name.required')
    end

    scenario "'about me' non-required committee members field", js: true do
      select("Rollins School of Public Health", from: "School")
      wait_for_ajax
      expect(page).not_to have_css('#help-members')
      expect(page).to have_css('input#etd_committee_members_0_name.optional')
      expect(page).to have_css('div.etd_committee_members_0_name.optional')
    end

    scenario "'about me' suppress partnering agencies", js: true do
      select("Laney Graduate School", from: "School")
      wait_for_ajax
      expect(page).not_to have_css('div.etd_partnering_agency')
    end

    scenario "'about me' not suppress partnering agencies", js: true do
      select("Rollins School of Public Health", from: "School")
      wait_for_ajax
      expect(page).to have_css('div.etd_partnering_agency')
    end

    scenario "'about me' adds and removes committee members", js: true do
      click_on("Add Another Committee Member")
      wait_for_ajax

      click_on("Add Another Committee Member")
      wait_for_ajax

      expect(all('select.committee-member-select').count).to eq(3)

      click_on("Remove Committee Member", match: :first)
      wait_for_ajax
      expect(all('select.committee-member-select').count).to eq(2)

      click_on("Remove Committee Member", match: :first)
      wait_for_ajax

      expect(all('select.committee-member-select').count).to eq(1)
    end

    scenario "'about me' adds and removes committee chairs", js: true do
      click_on("Add Another Committee Chair/Thesis Advisor")
      wait_for_ajax

      click_on("Add Another Committee Chair/Thesis Advisor")
      wait_for_ajax

      expect(all('select.committee-chair-select').count).to eq(3)

      click_on("Remove Committee Chair", match: :first)
      wait_for_ajax
      expect(all('select.committee-chair-select').count).to eq(2)

      click_on("Remove Committee Chair", match: :first)
      wait_for_ajax

      expect(all('select.committee-chair-select').count).to eq(1)
    end

    scenario "display indicates incomplete 'about me and my program' data", js: true do
      visit("/concern/etds/new")
      select('Emory Committee Chair', from: 'etd_committee_chair_0_affiliation_type')
      fill_in "Committee Chair/Thesis Advisor", with: "Diane Arbus"
      select('Non-Emory Committee Member', from: 'etd_committee_members_0_affiliation_type')
      fill_in "Committee Member", with: "Joan Didion"
      select('CDC', from: 'Partnering agency')
      click_on('Save About Me')

      expect(page).to have_css('li#required-about-me.incomplete')
      expect(page).not_to have_css('li#required-about-me.complete')
    end
  end
end
