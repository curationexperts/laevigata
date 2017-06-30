require 'rails_helper'
require 'etd_factory'

RSpec.feature 'Enforce file level embargoes' do
  before do
    allow(CharacterizeJob).to receive(:perform_later)
  end
  let(:etd) do
    etd_factory = EtdFactory.new
    etd_factory.etd = FactoryGirl.create(:sample_data_with_everything_embargoed)
    etd_factory.primary_pdf_file = "#{::Rails.root}/spec/fixtures/joey/joey_thesis.pdf"
    etd_factory.attach_primary_pdf_file
    etd_factory.etd
  end

  context 'public show page' do
    scenario "unauthorized user cannot download file from show page" do
      visit("/concern/etds/#{etd.id}")
      expect(page).to have_content etd.title.first
      expect(page).to have_content etd.creator.first
      expect(page).to have_content "Abstract"
      expect(page).not_to have_content etd.abstract.first
      expect(page).to have_content "This abstract is under embargo until"
      expect(page).to have_content "Table of Contents"
      expect(page).not_to have_content etd.table_of_contents.first
      expect(page).to have_content "This table of contents is under embargo until"
      expect(page).to have_content etd.rights_statement.first
      expect(page).not_to have_content "Download the file"
      expect(page).not_to have_link "joey_thesis.pdf"
      expect(page).not_to have_css "td.thumbnail/a/img" # thumbnail image link
    end
  end
end
