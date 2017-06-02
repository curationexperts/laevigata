require 'rails_helper'

RSpec.feature 'Display an ETD' do
  let(:etd) { build :etd }

  context 'a logged in user' do
    let(:user) { create :user }
    let(:research_field_label) { ResearchFieldService.new.label(etd.research_field.first) }

    before do
      login_as user
      etd.save
    end

    scenario "Show an ETD" do
      visit("/concern/etds/#{etd.id}")
      expect(page).to have_content etd.title.first
      expect(page).to have_content etd.creator.first
      expect(page).to have_content etd.keyword.first
      expect(page).to have_content etd.degree.first
      expect(page).to have_content etd.department.first
      expect(page).to have_content etd.school.first
      expect(page).to have_content etd.partnering_agency.first
      expect(page).to have_content etd.submitting_type.first
      expect(page).to have_content research_field_label
    end
  end
end
