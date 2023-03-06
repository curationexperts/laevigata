# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Password protect non production instances', type: :system do
  let(:login) { 'admin' }
  let(:password) { 'whatever' }

  before do
    ENV['HTTP_USERNAME'] = login
    ENV['HTTP_PASSWORD'] = password
  end

  context 'visiting an instance without HTTP_PASSWORD_PROTECT set' do
    it 'does not prompt the user for a password' do
      visit('/')
      expect(page).to have_content('Emory')
    end
  end

  context 'visiting an instance with HTTP_PASSWORD_PROTECT set' do
    before do
      ENV['HTTP_PASSWORD_PROTECT'] = 'true'
    end
    after do
      ENV['HTTP_PASSWORD_PROTECT'] = 'false'
    end
    it 'prompts the user for a password' do
      visit('/')
      expect(page.find(:xpath, '//body').text).to eq "HTTP Basic: Access denied."
    end
  end
end
