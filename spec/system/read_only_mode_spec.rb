# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Read Only Mode', type: :system, integration: true do
  before(:all) do
    skip("This test won't work if NEW_UI_ENABLED=true")
  end

  let(:student) { create :user }

  context 'a logged in user' do
    before do
      login_as student
    end

    scenario "View Etd Tabs", js: false do
      visit("/concern/etds/new")
      expect(page).to have_content("Submission Checklist")
      allow(Flipflop).to receive(:read_only?).and_return(true)
      visit("/concern/etds/new")
      expect(page).to have_content("This system is in read-only mode for maintenance.")
      allow(Flipflop).to receive(:read_only?).and_return(false)
      visit("/concern/etds/new")
      expect(page).to have_content("Submission Checklist")
    end
  end
end
