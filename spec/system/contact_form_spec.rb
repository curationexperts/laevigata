# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'contact form page', integration: true, smoke_test: true, type: :system do
  scenario 'contact form creation from libwizard', js: true do
    visit "/contact"

    expect(page.html).to match(/iframe/)
  end
end
