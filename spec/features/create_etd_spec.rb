# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Create a Etd' do
  context 'a logged in user' do
    let(:user_attributes) do
      { email: 'test@example.com' }
    end
    let(:user) do
      User.new(user_attributes) { |u| u.save(validate: false) }
    end

    before do
      login_as user
    end

    scenario "Submit a basic MS Word Thesis" do
      visit("/concern/etds/new")
      fill_in 'Title', with: 'China and its Minority Population'
      fill_in 'Creator', with: 'Eun, Dongwon'
      fill_in 'Keyword', with: 'China'
      # Department is not required, by default it is hidden as an additional field
      click_link("Additional fields")
      fill_in "Department", with: "Department of Russian and East Asian Languages and Cultures"
      select('All rights reserved', from: 'Rights')
      choose('open')
      check('agreement')
      click_on('Files')
      attach_file('files[]', "#{fixture_path}/emory_7tjfb-FILE")
      click_on('Save')
      expect(page).to have_content 'Your files are being processed'
      expect(page).to have_content 'deposited'
      expect(page).to have_content 'China and its Minority Population'

    end
  end
end
