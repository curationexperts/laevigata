require 'rails_helper'

RSpec.feature 'Display ETD metadata' do
  let(:etd) { FactoryGirl.create(:sample_data, partnering_agency: ["CDC"]) }
  # These are all the fields listed on our show wireframes
  let(:required_fields) do
    [
      "title",
      "creator",
      "graduation_year",
      "abstract",
      "table_of_contents",
      "school",
      "department",
      "degree",
      "submitting_type",
      "language",
      "subfield",
      "keyword",
      "committee_chair_name",
      "committee_members_names",
      "partnering_agency"
    ]
  end
  scenario "Show all expected ETD fields" do
    visit("/concern/etds/#{etd.id}")
    required_fields.each do |field|
      value = etd.send(field.to_sym).first
      expect(value).not_to eq nil
      expect(page).to have_content value
    end
  end
end
