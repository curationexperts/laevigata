# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Getting a 404 for RecordNotFound', type: :system do
  before do
  end
  context 'visiting a work that does not exist' do
    it 'has a 404 page' do
      visit('/concern/etds/invalid-id?locale=en')
      expect(page).to have_content('does not exist')
    end
  end

  context 'visiting a route with no content' do
    it 'has a 404 page' do
      visit('/bla/bla/bla')
      expect(page).to have_content('does not exist')
    end
  end
end
