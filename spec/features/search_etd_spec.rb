require 'rails_helper'

RSpec.feature 'Search for an ETD' do
  let(:etd) { build :eun_etd }

  context 'a logged in user' do
    let(:user) { create :user }

    before do
      login_as user
      etd.save
    end

    scenario "Search for an ETD" do
      visit("/")
      fill_in "q", with: "China"
      click_button "Go"
      # Uncomment this to display the HTML capybara is seeing
      # puts page.body
      expect(page).to have_content etd.title.first
      expect(page).to have_content etd.creator.first
      expect(page).to have_content etd.keyword.first
      expect(page).to have_content etd.degree.first
      expect(page).to have_content etd.department.first
      expect(page).to have_content etd.school.first
      expect(page).to have_content etd.subfield.first
      expect(page).to have_content etd.partnering_agency.first
      expect(page).to have_content etd.submitting_type.first
      expect(page).to have_content etd.research_field.last
      # Now look for degree in the facets on the left
      expect(page).to have_xpath("//h3", text: "Creator")
      expect(page).to have_link(etd.creator.first, class: "facet_select")
      expect(page).to have_xpath("//h3", text: "Degree")
      expect(page).to have_link(etd.degree.first, class: "facet_select")
      expect(page).to have_xpath("//h3", text: "Department")
      expect(page).to have_link(etd.department.first, class: "facet_select")
      expect(page).to have_xpath("//h3", text: "School")
      expect(page).to have_link(etd.school.first, class: "facet_select")
      expect(page).to have_xpath("//h3", text: "Sub Field")
      expect(page).to have_link(etd.subfield.first, class: "facet_select")
      expect(page).to have_xpath("//h3", text: "Research Field")
      expect(page).to have_link(etd.research_field.last, class: "facet_select")
    end
  end
end
