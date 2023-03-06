# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'show admin set', type: :system, integration: true do
  let(:admin_set) { FactoryBot.create(:admin_set) }
  let(:admin) { FactoryBot.create(:admin) }

  scenario "show admin set" do
    login_as admin
    visit("/admin/admin_sets/#{admin_set.id}")
    expect(page).to have_content admin_set.title.first
  end
end
