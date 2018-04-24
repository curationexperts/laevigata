require 'rails_helper'

RSpec.feature 'Collection objects should not appear in search results', :clean do
  let(:collection) {
    Collection.new(
      title: ["Fake Collection"],
      description: ["my fake collection"],
      visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    )
  }

  context 'a search for everything' do
    scenario "does not show a collection object" do
      expect(collection.save).to eq true
      visit("/")
      click_button "Go"
      expect(page).to have_content "No results found"
    end
  end
end
