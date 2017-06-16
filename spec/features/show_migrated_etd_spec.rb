require 'rails_helper'

RSpec.feature 'Display an ETD built from migrated content' do
  let(:etd) { build :ateer_etd }

  context 'a logged in user' do
    let(:user) { create :user }

    before do
      login_as user
      etd.save
    end

    scenario "ETD has embargo" do
      expect(etd.embargo).to be_instance_of Hydra::AccessControls::Embargo
      expect(etd.embargo.embargo_release_date).to eq "2017-08-21 00:00:00"
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
      # expect(page).to have_content research_field_label
    end
  end
end
