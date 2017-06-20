require 'rails_helper'

RSpec.feature 'Display an ETD built from migrated content' do
  let(:etd) { create :ateer_etd }

  context 'ateer_etd' do
    scenario "ETD has embargo" do
      expect(etd.embargo).to be_instance_of Hydra::AccessControls::Embargo
      expect(etd.embargo.embargo_release_date).to eq "2017-08-21 00:00:00"
    end

    scenario "ETD has no partnering_agency" do
      expect(etd.partnering_agency.count).to eq 0
    end

    scenario "Show an ETD" do
      visit("/concern/etds/#{etd.id}")
      expect(page).to have_content etd.title.first
      expect(page).to have_content etd.creator.first
      expect(page).to have_content etd.graduation_year
      expect(page).to have_content "About this #{etd.submitting_type.first}"
      expect(page).to have_content etd.school.first
      expect(page).to have_content etd.department.first
      expect(page).to have_content etd.degree.first
      expect(page).to have_content etd.submitting_type.first
      expect(page).to have_content etd.language.first
      expect(page).to have_content "http://pid.emory.edu/#{etd.identifier.first}" # Permanent URL
      expect(page).to have_content etd.research_field.first
      expect(page).to have_content etd.keyword.first
      expect(page).to have_content etd.rights_statement.first
      expect(page).to have_content "Treadway, Michael T"
      expect(page).to have_content "Craighead, W Edward"
      expect(page).to have_content "Manns, Joseph"
      expect(page).not_to have_content "Relationships"
      expect(page).to have_content "Abstract"
      expect(page).not_to have_content etd.abstract.first
      expect(page).to have_content "This abstract is under embargo until 21 August 2017"
      expect(page).to have_content "Table of Contents"
      expect(page).not_to have_content etd.table_of_contents.first
      expect(page).to have_content "This table of contents is under embargo until 21 August 2017"
      expect(page).to have_content etd.rights_statement.first
      click_on("Treadway, Michael T") # Search for all ETDs where this faculty member is the committee_chair
    end
  end
end
