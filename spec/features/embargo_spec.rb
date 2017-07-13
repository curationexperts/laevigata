# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'

include Warden::Test::Helpers

RSpec.feature 'Create an Etd: About My Etd' do
  let(:user) { create :user }

  context 'a logged in user' do
    before do
      login_as user
      visit("/concern/etds/new")
    end

    scenario "selecting Files sets files_embargoed value", js: true do
      click_on("My Embargoes")
      select('Files', from: "embargo_type")

      expect(find("#etd_files_embargoed", visible: false).value).to eq("true")
      expect(find("#etd_toc_embargoed", visible: false).value).to eq("false")
      expect(find("#etd_abstract_embargoed", visible: false).value).to eq("false")
    end

    scenario "selecting Files and Table of Contents sets files_embargoed and toc_embargoed values", js: true do
      click_on("My Embargoes")

      select('Files and Table of Contents', from: "embargo_type")
      expect(find("#etd_files_embargoed", visible: false).value).to eq("true")
      expect(find("#etd_toc_embargoed", visible: false).value).to eq("true")
      expect(find("#etd_abstract_embargoed", visible: false).value).to eq("false")
    end

    scenario "selecting Files and Table of Contents sets files_embargoed toc_embargoed and abstract_embargoed values", js: true do
      click_on("My Embargoes")

      select('Files, Table of Contents and Abstract', from: "embargo_type")
      expect(find("#etd_files_embargoed", visible: false).value).to eq("true")
      expect(find("#etd_toc_embargoed", visible: false).value).to eq("true")
      expect(find("#etd_abstract_embargoed", visible: false).value).to eq("true")
    end
  end
end
