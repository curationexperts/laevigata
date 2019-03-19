require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'show user profile', type: :system, integration: true do
  let(:user) { FactoryBot.create(:user) }

  scenario "show user profile but not email address" do
    visit("/users/#{user.user_key}")
    expect(page).not_to have_content user.email
  end
end
