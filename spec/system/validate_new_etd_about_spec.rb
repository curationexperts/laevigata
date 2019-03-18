require 'rails_helper'

include Warden::Test::Helpers

RSpec.describe 'Validate an Etd: About Me', type: :system, integration: true do
  let(:user) { create :user }

  context 'a logged in user' do
    before do
      login_as user
      visit("/concern/etds/new")
    end

    scenario "'about me' committee affiliation accepts user input when Non-Emory is selected", js: true unless continuous_integration? do
      select('Non-Emory Committee Member', from: 'etd_committee_members_attributes_0_affiliation_type')
      wait_for_ajax
      fill_in "etd[committee_members_attributes][0]_affiliation", with: "MOMA"
      expect(find_field("etd[committee_members_attributes][0]_affiliation").value).to eq("MOMA")
    end

    scenario "'about me' committee affiliation accepts user input when No Committee Members is selected", js: true unless continuous_integration? do
      select('No Committee Members', from: 'etd_committee_members_attributes_0_affiliation_type')
      wait_for_ajax
      expect(find_field("etd[committee_members_attributes][0]_affiliation").value).to eq("N/A")
      expect(find_field("etd[committee_members_attributes][0][name][]").value).to eq("N/A")
    end

    scenario "'about me' adds and removes committee members", js: true unless continuous_integration? do
      click_on("Add another Committee Member")
      wait_for_ajax

      click_on("Add another Committee Member")
      wait_for_ajax

      expect(all('select.committee-member-select').count).to eq(3)

      click_on("Remove Committee Member", match: :first)
      wait_for_ajax
      expect(all('select.committee-member-select').count).to eq(2)

      click_on("Remove Committee Member", match: :first)
      wait_for_ajax

      expect(all('select.committee-member-select').count).to eq(1)
    end

    scenario "'about me requires Partnering Agency for Rollins School'", js: true unless continuous_integration? do
      fill_in 'Student Name', with: 'Eun, Dongwon'
      select("Spring 2018", from: "Graduation Date")
      fill_in "Post Graduation Email", with: "graduate@done.com"
      select("Rollins School of Public Health", from: "School")
      wait_for_ajax
      select("Biostatistics", from: "Department")

      select('MS', from: "Degree")
      select("Honors Thesis", from: "Submission Type")
      fill_in "Committee Chair/Thesis Advisor", with: "Diane Arbus"
      fill_in "etd[committee_members_attributes][0][name][]", with: "Joan Didion"

      expect(page).not_to have_css('li#required-about-me.complete')

      select('CDC', from: 'Partnering Agency')

      expect(page).to have_css('li#required-about-me.complete')
    end

    scenario "'about me and my program' requires non-emory committee member affiliation", js: true unless continuous_integration? do
      fill_in 'Student Name', with: 'Eun, Dongwon'
      select("Spring 2018", from: "Graduation Date")
      fill_in "Post Graduation Email", with: "graduate@done.com"
      select("Laney Graduate School", from: "School")
      select("Religion", from: "Department")
      select("Ethics and Society", from: "Sub Field")
      select('MS', from: "Degree")
      select("Honors Thesis", from: "Submission Type")
      fill_in "Committee Chair/Thesis Advisor", with: "Diane Arbus"
      select('Non-Emory Committee Chair', from: "Committee Chair/Thesis Advisor's Affiliation")
      fill_in('etd_committee_chair_0_affiliation', with: 'Oxford')
      fill_in "etd[committee_members_attributes][0][name][]", with: "Joan Didion"

      click_on('About Me')
      wait_for_ajax(5)

      expect(page).to have_css('li#required-about-me.complete')
    end
  end
end
