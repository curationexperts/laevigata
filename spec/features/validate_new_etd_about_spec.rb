require 'rails_helper'

include Warden::Test::Helpers

RSpec.feature 'Validate an Etd: About Me' do
  let(:user) { create :user }

  context 'a logged in user' do
    before do
      login_as user
      visit("/concern/etds/new")
    end

    # TODO: need another one of these for chairs: scenario "'about me' adds and removes committee members"
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

    scenario "'about me requires Partnering Agency for Rollins School'", js: true do
      fill_in 'Student Name', with: 'Eun, Dongwon'
      select("Spring 2018", from: "Graduation date")
      fill_in "Post graduation email", with: "graduate@done.com"
      select("Rollins School of Public Health", from: "School")
      select("Biostatistics", from: "Department")
      select('MS', from: "Degree")
      select("Honors Thesis", from: "I am submitting my")
      fill_in "Committee Chair/Thesis Advisor", with: "Diane Arbus"
      fill_in "Committee Member", with: "Joan Didion"

      expect(page).not_to have_css('li#required-about-me.complete')
      expect(page).to have_css('li#required-about-me.incomplete')

      select('CDC', from: 'Partnering agency', visible: false)

      expect(page).to have_css('li#required-about-me.complete')
      expect(page).not_to have_css('li#required-about-me.incomplete')
    end

    scenario "'about me and my program' requires non-emory committee member affiliation", js: true do
      fill_in 'Student Name', with: 'Eun, Dongwon'
      select("Spring 2018", from: "Graduation date")
      fill_in "Post graduation email", with: "graduate@done.com"
      select("Laney Graduate School", from: "School")
      select("Religion", from: "Department")
      select("Ethics and Society", from: "Sub Field")
      select('MS', from: "Degree")
      select("Honors Thesis", from: "I am submitting my")
      fill_in "Committee Chair/Thesis Advisor", with: "Diane Arbus"
      select('Non-Emory Committee Chair', from: "Committee Chair/Thesis Advisor's Affiliation")
      fill_in('etd_committee_chair_0_affiliation', with: 'Oxford')
      fill_in "Committee Member", with: "Joan Didion"

      click_on('Save About Me')

      expect(page).to have_content 'Successfully saved About: Eun, Dongwon'
      expect(page).to have_css('li#required-about-me.complete')
      expect(page).not_to have_css('li#required-about-me.incomplete')
    end
  end
end
