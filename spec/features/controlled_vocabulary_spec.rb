require 'rails_helper'

include Warden::Test::Helpers

RSpec.feature 'Using Controlled Vocabularies', :workflow, integration: true do
  let(:admin) { create(:admin) }
  let(:user)  { create(:user) }

  let(:etd) do
    actor_create(:etd,
                 title: ['Another great thesis by Frodo'],
                 creator: ['Johnson, Frodo'],
                 graduation_date: ['2013'],
                 post_graduation_email: ['frodo@example.com'],
                 school: ['Emory College'],
                 department: ['Religion'],
                 degree: ['Ph.D.'],
                 submitting_type: ['Dissertation'],
                 language: ['English'],
                 abstract: ['<p>Literature from the US</p>'],
                 table_of_contents: ['<h1>Chapter One</h1>'],
                 research_field: ['Aeronomy'],
                 keyword: ['key1'],
                 requires_permissions: false,
                 other_copyrights: true,
                 patents: false,
                 files_embargoed: false,
                 abstract_embargoed: false,
                 toc_embargoed: false,
                 embargo_length: nil,
                 user: user)
  end

  before do
    new_ui = Rails.application.config_for(:new_ui).fetch('enabled', false)
    skip("This test won't work if NEW_UI_ENABLED=true") if new_ui

    login_as admin
  end

  scenario 'has existing value selected' do
    visit edit_hyrax_etd_path(etd)

    expect(page).to have_select('etd_graduation_date', selected: '2013')
  end
end
