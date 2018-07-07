require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Admin dashboard',
              integration: true,
              workflow: { admin_sets_config: 'spec/fixtures/config/emory/epidemiology_admin_sets.yml' } do

  context 'as an admin user' do
    let(:user) { FactoryBot.create(:admin) }

    scenario 'view the admin statistics page' do
      login_as user
      visit '/dashboard'
      click_on 'Reports'
      expect(page).to have_content 'Work Statistics'
    end

    scenario 'manage users and see admin users' do
      login_as user
      visit '/dashboard'
      click_on 'Manage Users'
      expect(page).to have_content 'Last access'
    end

    scenario 'school config' do
      login_as user
      visit '/dashboard'
      click_on 'Schools'
      expect(page).to have_content 'Candler School of Theology'
    end
  end
end
