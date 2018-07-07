require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'show admin set', integration: true do
  let(:admin_set) { FactoryBot.create(:admin_set) }
  let(:admin) { FactoryBot.create(:admin) }

  scenario "show admin set" do
    login_as admin
    visit("/admin/admin_sets/#{admin_set.id}")
    expect(page).to have_content admin_set.title.first
  end
end
