require 'rails_helper'
require 'active_fedora/cleaner'
require 'workflow_setup'
require 'etd_factory'
include Warden::Test::Helpers

RSpec.feature 'Display an ETD with embargoed content' do
  let(:etd) do
    etd = FactoryGirl.create(:sample_data_with_everything_embargoed)
    etd_factory = EtdFactory.new
    primary_pdf_file = "#{::Rails.root}/spec/fixtures/joey/joey_thesis.pdf"
    etd_factory.etd = etd
    etd_factory.primary_pdf_file = primary_pdf_file
    etd_factory.attach_primary_pdf_file
    etd.save
    etd
  end
  let(:w) { WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/candler_admin_sets.yml", "/dev/null") }
  let(:depositor) { User.where(ppid: etd.depositor).first }
  let(:approver) { User.where(ppid: 'candleradmin').first }
  before do
    ActiveFedora::Cleaner.clean!
    w.setup
    allow(CharacterizeJob).to receive(:perform_later) # There is no fits installed on travis-ci
  end
  context 'embargoed work display' do
    scenario "viewed by a school approver" do
      expect(etd.school.first).to eq "Candler School of Theology"
      login_as approver
      visit("/concern/etds/#{etd.id}")
      expect(page).to have_content "Abstract"
      expect(page).to have_content etd.abstract.first
      expect(page).to have_content "[Abstract embargoed until "
      expect(page).to have_content "Table of Contents"
      expect(page).to have_content etd.table_of_contents.first
      expect(page).to have_content "[Table of content embargoed until "
      expect(page).to have_content "joey_thesis.pdf"
      expect(page).to have_link "joey_thesis.pdf"
      expect(page).to have_link "Download"
      expect(page).to have_css "td.thumbnail/a/img" # thumbnail image link
    end
    scenario "viewed by unauthenticated user" do
      visit("/concern/etds/#{etd.id}")
      expect(page).to have_content "Abstract"
      expect(page).not_to have_content etd.abstract.first
      expect(page).to have_content "This abstract is under embargo until"
      expect(page).to have_content "Table of Contents"
      expect(page).not_to have_content etd.table_of_contents.first
      expect(page).to have_content "This table of contents is under embargo until"
      expect(page).not_to have_content "joey_thesis.pdf"
      expect(page).not_to have_link "joey_thesis.pdf"
      expect(page).not_to have_link "Download"
      expect(page).not_to have_css "td.thumbnail/a/img" # thumbnail image link
    end
  end
end
