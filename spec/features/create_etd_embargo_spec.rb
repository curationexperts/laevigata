# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'

include Warden::Test::Helpers

RSpec.feature 'Create an Etd: My Embargoes' do
  let(:user) { create :user }

  context 'a logged in user' do
    before do
      login_as user
      visit("/concern/etds/new")
    end

    scenario "Embargo fields are present in tab" do
      click_on("Embargoes")

      expect(page).to have_content("What do you want to embargo?")
      expect(page).to have_content("Select your school")
      expect(page).to have_content("How long will the embargo last?")
      expect(page).to have_css('#save_my_embargoes')
    end

    scenario "Checking 'No embargoes' makes invalid form valid", js: true unless continuous_integration? do
      click_on("Embargoes")

      expect(page).to have_css('li#required-embargoes.incomplete')

      check('no_embargoes')

      expect(page).to have_css('li#required-embargoes.complete')
    end

    scenario "Unchecking 'No embargoes' makes valid form invalid", js: true unless continuous_integration? do
      click_on("Embargoes")

      expect(page).to have_css('li#required-embargoes.incomplete')

      check('no_embargoes')

      expect(page).to have_field('no_embargoes', checked: true)

      expect(page).to have_css('li#required-embargoes.complete')

      uncheck('no_embargoes')

      expect(page).to have_field('no_embargoes', checked: false)
      expect(page).to have_css('li#required-embargoes.incomplete')
    end

    scenario "selecting Files sets files_embargoed value", js: true unless continuous_integration? do
      click_on("Embargoes")
      select('Files', from: "embargo_type")

      expect(find("#etd_files_embargoed", visible: false).value).to eq("true")
      expect(find("#etd_toc_embargoed", visible: false).value).to eq("false")
      expect(find("#etd_abstract_embargoed", visible: false).value).to eq("false")
    end

    scenario "selecting Files and Table of Contents sets files_embargoed and toc_embargoed values", js: true unless continuous_integration? do
      click_on("Embargoes")

      select('Files and Table of Contents', from: "embargo_type")
      expect(find("#etd_files_embargoed", visible: false).value).to eq("true")
      expect(find("#etd_toc_embargoed", visible: false).value).to eq("true")
      expect(find("#etd_abstract_embargoed", visible: false).value).to eq("false")
    end

    scenario "selecting Files and Table of Contents sets files_embargoed toc_embargoed and abstract_embargoed values", js: true unless continuous_integration? do
      click_on("Embargoes")

      select('Files, Table of Contents and Abstract', from: "embargo_type")
      expect(find("#etd_files_embargoed", visible: false).value).to eq("true")
      expect(find("#etd_toc_embargoed", visible: false).value).to eq("true")
      expect(find("#etd_abstract_embargoed", visible: false).value).to eq("true")
    end

    scenario "each school has its own option", js: true unless continuous_integration? do
      click_on("Embargoes")

      expect(page).to have_select('embargo_school', options: ['', 'Emory College', 'Rollins School of Public Health', 'Candler School of Theology', 'Laney Graduate School'])
    end

    scenario "each school sets the correct embargo lengths", js: true unless continuous_integration? do
      click_on("Embargoes")

      select('Laney Graduate School', from: 'embargo_school')

      expect(page).to have_select('etd_embargo_length', options: ["", "6 months", "1 year", "2 years", "6 years"])

      select('Emory College', from: 'embargo_school')

      expect(page).to have_select('etd_embargo_length', options: ["", "6 months", "1 year", "2 years"])

      select('Rollins School of Public Health', from: 'embargo_school')

      expect(page).to have_select('etd_embargo_length', options: ["", "6 months", "1 year", "2 years"])

      select('Candler School of Theology', from: 'embargo_school')

      expect(page).to have_select('etd_embargo_length', options: ["", "6 months", "1 year", "2 years"])
    end

    scenario "Selecting embargo types and embargo length makes invalid form valid", js: true do
      click_on("Embargoes")

      expect(page).to have_content('What do you want to embargo?')

      expect(page).to have_css('li#required-embargoes.incomplete')

      select('Files and Table of Contents', from: 'embargo_type')

      select('Laney Graduate School', from: 'embargo_school')

      select('6 months', from: 'etd_embargo_length')

      expect(page).to have_css('li#required-embargoes.complete')
    end
  end
end
