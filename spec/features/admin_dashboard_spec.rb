require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Admin dashboard',
              integration: true,
              workflow: { admin_sets_config: 'spec/fixtures/config/emory/candler_admin_sets.yml' } do

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

  context 'as an approving user' do
    let(:user)     { User.find_by(ppid: 'candleradmin') }
    let(:etd)      { FactoryBot.build(:sample_data_with_everything_embargoed) }
    let(:file_set) { FactoryBot.create(:public_pdf) }

    before do
      etd.ordered_members << file_set
      etd.representative = file_set
      etd.save

      login_as user
    end

    scenario 'editing an embargo' do
      visit '/dashboard'
      click_link 'Manage Embargoes'
      click_link etd.first_title
      select 'Restricted; Files Only', from: 'etd_visibility_during_embargo'
      fill_in 'etd_embargo_release_date', with: '2199-01-01'
      click_button 'Update Embargo'

      etd.reload
      expect(etd.embargo_release_date).to eq Date.parse('2199-01-01')
      expect(etd.visibility).to eq VisibilityTranslator::FILES_EMBARGOED

      expect(etd.representative.visibility)
        .to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
      expect(etd.representative.embargo_release_date)
        .to eq Date.parse('2199-01-01')
    end
  end
end
