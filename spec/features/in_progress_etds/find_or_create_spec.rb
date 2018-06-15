require 'rails_helper'

include Warden::Test::Helpers

RSpec.feature 'Find or Create an In-progress ETD' do
  let(:user) { create :user }
  before do
    login_as user
    visit("/concern/etds/new")
  end

  scenario 'the first time a user visits the new ETD view', new_ui: true do
    # save a new etd
    fill_in 'Name', with: 'Eun, Dongwon'
    fill_in 'Email', with: 'graduate@done.com'
    fill_in 'Graduation date', with: 'Summer 2020'
    fill_in 'Submission type', with: 'Honors Thesis'
    click_on 'Save'

    expect(page).to have_content('Your In-Progress ETD')
  end

  context 'any subsequent time a user visits the new ETD view', new_ui: true do
    scenario 'the response is their in-progress ETD' do
      # save a new etd
      fill_in 'Name', with: 'Miranda'
      fill_in 'Email', with: 'graduate@super-done.com'
      fill_in 'Graduation date', with: 'Summer 2022'
      fill_in 'Submission type', with: 'Master Thesis'
      click_on 'Save'
      expect(page).to have_content('Miranda')

      visit("/concern/etds/new")

      expect(find_field('Name').value).to eq('Miranda')
      expect(find_field('Email').value).to eq('graduate@super-done.com')
      expect(find_field('Graduation date').value).to eq('Summer 2022')
      expect(find_field('Submission type').value).to eq('Master Thesis')
    end
  end
end
