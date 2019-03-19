# Generated via `rails generate hyrax:work Etd`
require 'rails_helper'

include Warden::Test::Helpers

RSpec.describe 'Edit an existing ETD', :clean, integration: true, type: :system do
  before(:all) do
    new_ui = Rails.application.config_for(:new_ui).fetch('enabled', false)
    skip("This test only works if NEW_UI_ENABLED=true") unless new_ui
  end

  context "no unauthorized users can see a student's in progress ETD" do
    let(:ipe) { FactoryBot.create(:in_progress_etd, user_ppid: depositor.ppid) }
    let(:depositor) { FactoryBot.create(:user) }
    let(:another_user) { FactoryBot.create(:user) }

    # An unauthenticated user should never be able to access
    # an edit form
    scenario "unauthenticated user visits edit form" do
      visit "/in_progress_etds/#{ipe.id}/edit"
      expect(current_url).to match(/sign_in/)
    end
    scenario "a user visits some else's edit form" do
      login_as another_user
      visit "/in_progress_etds/#{ipe.id}/edit"
      expect(page).to have_content "Unauthorized"
    end
    # No one should be able to fish around for id numbers of
    # in progress ETDs
    scenario "a user visits a nonexistent edit form" do
      login_as another_user
      visit "/in_progress_etds/9999/edit"
      expect(current_url).to match(/\?locale\=en/)
    end
  end
end
