require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Admin Statistics' do
  before { login_as(user) }

  context 'as an admin user' do
    let(:user) { FactoryBot.create(:admin) }

    scenario 'view the admin statistics page' do
      visit '/dashboard'
      click_on 'Reports'

      expect(page).to have_content 'Work Statistics'
    end
  end
end
