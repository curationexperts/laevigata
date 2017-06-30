require 'rails_helper'
require 'etd_factory'
require 'workflow_setup'
require 'active_fedora/cleaner'
include Warden::Test::Helpers

RSpec.describe EtdFactory do
  before :all do
    ActiveFedora::Cleaner.clean!
    wf = WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/", "#{::Rails.root}/config/emory/schools.yml", "/dev/null")
    wf.setup
  end
  before do
    allow(CharacterizeJob).to receive(:perform_later) # There is no fits installed on travis-ci
  end
  let(:etd_factory) { described_class.new }
  it "can be instantiated" do
    expect(etd_factory).to be_instance_of described_class
  end
  it "accepts an etd object" do
    ateer = FactoryGirl.build(:ateer_etd)
    etd_factory.etd = ateer
    expect(etd_factory.etd).to be_instance_of Etd
  end
  it "accepts a primary pdf file" do
    file = "#{::Rails.root}/spec/fixtures/joey/joey_thesis.pdf"
    etd_factory.primary_pdf_file = file
    expect(etd_factory.primary_pdf_file).to eq file
  end
  it "assigns an admin set based on the school" do
    etd_factory.etd = FactoryGirl.create(:etd, school: ["Laney Graduate School"])
    etd_factory.assign_admin_set
    expect(etd_factory.etd.admin_set.title).to eq ["Laney Graduate School"]
  end
  context "attaching primary pdf to etd" do
    let(:attached_etd) do
      etd_factory.etd = FactoryGirl.create(:ateer_etd)
      etd_factory.primary_pdf_file = "#{::Rails.root}/spec/fixtures/joey/joey_thesis.pdf"
      etd_factory.attach_primary_pdf_file
      etd_factory.etd
    end
    let(:primary_pdf_fs) { attached_etd.ordered_members.to_a.first }
    it "attaches a pdf" do
      expect(attached_etd.members.first).to be_instance_of FileSet
      expect(attached_etd.members.first.label).to eq "joey_thesis.pdf"
    end
    context "files_embargoed"
    it "copies the embargo to the pdf file if files_embargoed == true" do
      expect(attached_etd.files_embargoed).to eq true
      expect(primary_pdf_fs.embargo_id).to eq attached_etd.embargo_id
      expect(primary_pdf_fs.visibility).to eq "open"
    end
    it "marks the primary_pdf as primary" do
      expect(primary_pdf_fs.primary).to match(/primary/)
    end
  end
end
