require 'rails_helper'
require 'workflow_setup'
require 'etd_factory'
include Warden::Test::Helpers

RSpec.feature 'Display an ETD with embargoed content', :clean do
  let(:etd) do
    etd = FactoryBot.create(:sample_data_with_everything_embargoed, school: ["Candler School of Theology"])
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
    w.setup
    allow(CharacterizeJob).to receive(:perform_later) # There is no fits installed on travis-ci
  end
  context 'embargoed work display' do
    scenario "viewed by depositor pre-graduation" do
      etd.embargo_length = "6 months"
      etd.save
      expect(etd.degree_awarded).to eq nil
      login_as depositor
      visit("/concern/etds/#{etd.id}")
      expect(page).to have_content "Abstract"
      expect(page).to have_content etd.abstract.first
      expect(page).to have_content "[Abstract embargoed until #{etd.embargo_length} post-graduation"
      expect(page).to have_content "Table of Contents"
      expect(page).to have_content etd.table_of_contents.first
      expect(page).to have_content "[Table of contents embargoed until #{etd.embargo_length} post-graduation"
      expect(page).to have_content etd.title.first
      expect(page).to have_link etd.title.first
      expect(page).to have_link "Download"
      expect(page).to have_css "td.thumbnail/a/img" # thumbnail image link
    end
    scenario "viewed by depositor post-graduation" do
      etd.embargo_length = "6 months"
      etd.degree_awarded = Date.parse("17-05-17").strftime("%d %B %Y")
      etd.save
      login_as depositor
      visit("/concern/etds/#{etd.id}")
      expect(page).to have_content "Abstract"
      expect(page).to have_content etd.abstract.first
      expect(page).to have_content "[Abstract embargoed until #{formatted_embargo_release_date(etd)}"
      expect(page).to have_content "Table of Contents"
      expect(page).to have_content etd.table_of_contents.first
      expect(page).to have_content "[Table of contents embargoed until #{formatted_embargo_release_date(etd)}"
      expect(page).to have_content etd.title.first
      expect(page).to have_link etd.title.first
      expect(page).to have_link "Download"
      expect(page).to have_css "td.thumbnail/a/img" # thumbnail image link
    end
    scenario "viewed by a school approver pre-graduation" do
      etd.embargo_length = "6 months"
      etd.save
      expect(etd.degree_awarded).to eq nil
      login_as approver
      visit("/concern/etds/#{etd.id}")
      expect(page).to have_content "Abstract"
      expect(page).to have_content etd.abstract.first
      expect(page).to have_content "[Abstract embargoed until #{etd.embargo_length} post-graduation"
      expect(page).to have_content "Table of Contents"
      expect(page).to have_content etd.table_of_contents.first
      expect(page).to have_content "[Table of contents embargoed until #{etd.embargo_length} post-graduation"
      expect(page).to have_content etd.title.first
      expect(page).to have_link etd.title.first
      expect(page).to have_link "Download"
      expect(page).to have_css "td.thumbnail/a/img" # thumbnail image link
    end
    scenario "viewed by a school approver post-graduation" do
      etd.degree_awarded = Date.parse("17-05-17").strftime("%d %B %Y")
      etd.save
      login_as approver
      visit("/concern/etds/#{etd.id}")
      expect(page).to have_content "Abstract"
      expect(page).to have_content etd.abstract.first
      expect(page).to have_content "[Abstract embargoed until #{formatted_embargo_release_date(etd)}"
      expect(page).to have_content "Table of Contents"
      expect(page).to have_content etd.table_of_contents.first
      expect(page).to have_content "[Table of contents embargoed until #{formatted_embargo_release_date(etd)}"
      expect(page).to have_content etd.title.first
      expect(page).to have_link etd.title.first
      expect(page).to have_link "Download"
      expect(page).to have_css "td.thumbnail/a/img" # thumbnail image link
    end
    scenario "viewed by unauthenticated user post-graduation" do
      etd.degree_awarded = Date.parse("17-05-17").strftime("%d %B %Y")
      visit("/concern/etds/#{etd.id}")
      expect(page).to have_content "Abstract"
      expect(page).not_to have_content etd.abstract.first
      expect(page).to have_content "This abstract is under embargo until #{formatted_embargo_release_date(etd)}"
      expect(page).to have_content "Table of Contents"
      expect(page).not_to have_content etd.table_of_contents.first
      expect(page).to have_content "This table of contents is under embargo until #{formatted_embargo_release_date(etd)}"
      expect(page).not_to have_link etd.title.first
      expect(page).not_to have_link "Download"
      expect(page).to have_css "td.thumbnail/img[alt='No preview']" # "no preview" image
      expect(page).to have_css "img.representative-media[alt='No preview']" # "no preview" large image
    end
  end
  def formatted_embargo_release_date(etd)
    etd.embargo.embargo_release_date.strftime("%d %B %Y")
  end
end
