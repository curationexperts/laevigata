require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Login a User' do
  context 'a logged out user' do

    scenario 'Submit an ETD' do
      visit(root_url)
      click_link('Share Your Work')
      expect(page).to have_xpath('//h2', text: 'Log in')
      expect(page).to have_button('Log in')
    end
  end
end
