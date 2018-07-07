require 'rails_helper'

RSpec.feature 'Collection objects should not appear in search results',
              :clean, integration: true do
  let(:collection) { build(:collection) }

  context 'a search for everything' do
    before { collection.save }

    scenario "does not show a collection object" do
      visit("/")
      click_button "Go"
      expect(page).to have_content "No results found"
    end
  end
end
