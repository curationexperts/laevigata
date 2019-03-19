require 'rails_helper'

RSpec.describe 'Skip the dashboard', type: :system, integration: true do
  let(:user) { FactoryBot.create(:user) }

  context 'an unauthenticated user' do
    scenario "gets a button to submit a new ETD" do
      visit("/")
      expect(
        find_link('Submit My ETD', class: "btn btn-primary")[:href].gsub('?locale=en', '')
      ).to eq new_hyrax_etd_path
    end
  end

  context 'a logged in user' do
    before do
      login_as user
    end

    scenario "gets a button to submit a new ETD" do
      visit("/")
      expect(
        find_link('Submit My ETD', class: "btn btn-primary")[:href].gsub('?locale=en', '')
      ).to eq new_hyrax_etd_path
    end
  end
end
