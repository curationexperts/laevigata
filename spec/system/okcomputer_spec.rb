# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'OkCompuer checks', type: :system do
  it 'has checks configured', :aggregate_failures do
    visit '/okcomputer/all'

    expect(page).to have_content('batch_queue: PASSED')
    expect(page).to have_content('database: PASSED')
    expect(page).to have_content('default: PASSED')
    expect(page).to have_content('default_queue: PASSED')
    expect(page).to have_content('derivatives_queue: PASSED')
    expect(page).to have_content('etd_load:') # There may or may not be ETDs depending on test order
    expect(page).to have_content('ingest_queue: PASSED')
    expect(page).to have_content('smtp: FAILED ')
  end

  it 'Checks SMTP' do
    # Stub a working SMTP connection
    smtp = Net::SMTP.new(ENV['ACTION_MAILER_SMTP_ADDRESS'], ENV['ACTION_MAILER_PORT'])
    allow(smtp).to receive(:start).and_yield('dummy')
    allow(Net::SMTP).to receive(:new).and_return(smtp)

    visit '/okcomputer/all'
    expect(page).to have_content('smtp: PASSED')
  end
end
