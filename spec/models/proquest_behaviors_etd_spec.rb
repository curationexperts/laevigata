# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'
require 'workflow_setup'
include Warden::Test::Helpers
RSpec.describe Etd, :perform_jobs, :clean do
  let(:etd) { FactoryBot.create(:ready_for_proquest_submission_phd) }
  context "ProQuest submission" do
    let(:w) { WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/laney_admin_sets.yml", "/dev/null") }
    let(:proquest_dtd) { "#{fixture_path}/proquest/Dissertations_metadata48.dtd" }
    let(:output_xml) { "#{fixture_path}/proquest/output.xml" }
    let(:user) { User.where(ppid: etd.depositor).first }
    let(:ability) { ::Ability.new(user) }
    let(:file1_path) { "#{::Rails.root}/spec/fixtures/joey/joey_thesis.pdf" }
    let(:file2_path) { "#{::Rails.root}/spec/fixtures/miranda/image.tif" }
    let(:upload1) do
      File.open(file1_path) do |file1|
        Hyrax::UploadedFile.create(user: user, file: file1, pcdm_use: 'primary')
      end
    end
    let(:upload2) do
      File.open(file2_path) do |file2|
        Hyrax::UploadedFile.create(
          user: user,
          file: file2,
          pcdm_use: 'supplementary',
          description: 'Description of the supplementary file',
          file_type: 'Image'
        )
      end
    end
    let(:actor) { Hyrax::CurationConcern.actor }
    let(:attributes_for_actor) { { uploaded_files: [upload1.id, upload2.id] } }
    let(:approving_user) { User.where(ppid: 'laneyadmin').first }
    let(:env) { Hyrax::Actors::Environment.new(etd, ability, attributes_for_actor) }

    before do
      allow(CharacterizeJob).to receive(:perform_later) # There is no fits installed on travis-ci
      w.setup
      actor.create(env)
      subject = Hyrax::WorkflowActionInfo.new(etd, approving_user)
      sipity_workflow_action = PowerConverter.convert_to_sipity_action("approve", scope: subject.entity.workflow) { nil }
      Hyrax::Workflow::WorkflowActionService.run(subject: subject, action: sipity_workflow_action, comment: "Preapproved")
      etd.state = Vocab::FedoraResourceStatus.active # simulates GraduationJob
      etd.save
      # Fake the data that would normally be created by CharacterizeJob
      primary_pdf_fs = etd.members.select { |a| a.pcdm_use == "primary" }.first
      page_count_predicate = "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#pageCount"
      allow(primary_pdf_fs.files.first.metadata).to receive(:attributes) { { page_count_predicate => ["7"] } }
    end
    it "exports valid ProQuest XML" do
      skip "DTD validation seems to be broken in nokogiri"
      File.open(output_xml, 'w') { |file| file.write(etd.export_proquest_xml) }
      dtd_doc = Nokogiri::XML::Document.parse(File.read(proquest_dtd))
      dtd = Nokogiri::XML::DTD.new('protocol', dtd_doc)
      doc = Nokogiri::XML(File.read(output_xml))
      puts dtd.validate(doc)
    end
    it "exports well formed XML" do
      allow(etd).to receive(:depositor).and_return("P0000002")
      allow(etd).to receive(:abstract).and_return(Array.wrap(File.read("#{fixture_path}/proquest/tinymce_output.txt")))
      File.open(output_xml, 'w') { |file| file.write(etd.export_proquest_xml) }
      expect { Nokogiri::XML(etd.export_proquest_xml) }.not_to raise_error
      doc = Nokogiri::XML(etd.export_proquest_xml)
      expect(doc.xpath('//DISS_para').count).to be > 0
    end
    it "gets the page count of the primary PDF" do
      expect(etd.page_count).to eq "7"
    end
    it "gets the primary pdf filename" do
      expect(etd.primary_pdf_file_name).to eq "joey_thesis.pdf"
    end
    it "starts export package with upload_" do
      expect(etd.upload_file_id).to match(/^upload_/)
    end
    it "names data file according to ProQuest specs" do
      expect(etd.xml_filename).to match(/_DATA.xml/)
    end
    it "names the supplemental files dir as directed" do
      expect(etd.supplemental_files_directory).to match(/_Media/)
    end
    context "exporting packages" do
      it "zips the exported directory" do
        allow(etd).to receive(:depositor).and_return("P0000002")
        etd.export_zipped_proquest_package
        export_file = "#{etd.export_directory}/#{etd.upload_file_id}.zip"
        expect(File.exist?(export_file)).to eq true
        File.delete(export_file)
      end
    end
  end

  context "proquest embargo codes" do
    it "no embargo" do
      etd.embargo_length = nil
      expect(etd.embargo_code).to eq 0
    end
    it "6 months" do
      etd.embargo_length = "6 months"
      expect(etd.embargo_code).to eq 1
    end
    it "1 year" do
      etd.embargo_length = "1 year"
      expect(etd.embargo_code).to eq 2
    end
    it "2 years" do
      etd.embargo_length = "2 years"
      expect(etd.embargo_code).to eq 3
    end
    it "6 years" do
      etd.embargo_length = "6 years"
      expect(etd.embargo_code).to eq 4
    end
  end

  context "abstract formatting" do
    it "transforms tinymce output into something proquest can handle" do
      tinymce_output = File.read("#{fixture_path}/proquest/tinymce_output.txt")
      doc = etd.mce_to_proquest(tinymce_output)
      expect(doc).not_to match(/textarea/)
      expect(doc).not_to match(/h1/)
      expect(doc).not_to match(/h2/)
      expect(doc).not_to match(/h3/)
      expect(doc).not_to match(/h4/)
      expect(doc).not_to match(/h5/)
      expect(doc).not_to match(/text-align/)
      expect(doc).not_to match(/img/)
      expect(doc).not_to match(/<br/)
      expect(doc).not_to match(/span/)
      expect(doc).to match(/DISS_para/)
      expect(doc).to match(/italic/)
      expect(doc).to match(/This is an abstract./)
    end
  end

  context "Language codes" do
    it "transforms a language string into a ProQuest expected language code" do
      etd.language = ["English"]
      expect(etd.proquest_language).to eq "EN"
      etd.language = ["French"]
      expect(etd.proquest_language).to eq "FR"
      etd.language = ["Spanish"]
      expect(etd.proquest_language).to eq "SP"
    end
  end

  context "proquest submission type" do
    it "returns either 'masters' or 'doctoral'" do
      etd.submitting_type = ["Master's Thesis"]
      expect(etd.proquest_submission_type).to eq "masters"
      etd.submitting_type = ["Dissertation"]
      expect(etd.proquest_submission_type).to eq "doctoral"
    end
  end

  context "DISS_accept_date" do
    it "formats the degree awarded date as expected" do
      expect(etd.proquest_diss_accept_date).to eq Date.parse(etd.degree_awarded.to_s).strftime("%m/%d/%Y")
    end
  end

  context "ProQuest research field" do
    it "associates research codes" do
      expect(etd.proquest_code("Artificial Intelligence")).to eq "0800"
      expect(etd.proquest_code("Canadian Studies")).to eq "0385"
      expect(etd.proquest_code("Folklore")).to eq "0358"
    end
  end

  context "registrar data" do
    it "can load registrar data from a configurable location" do
      registrar_data = etd.load_registrar_data_for_user("P0000001")
      expect(registrar_data["home address 1"]).to eq "123 Fake St"
    end
  end

  context "proquest submission" do
    it "allows the student to choose whether to submit" do
      expect(etd.choose_proquest_submission).to be_empty
      etd.choose_proquest_submission = [true]
      expect(etd.choose_proquest_submission.first).to eq(true)
    end
    it "records the date the etd was submitted to proquest" do
      expect(etd.proquest_submission_date).to be_empty
      expect(etd.proquest_submission_date.first.instance_of?(Date)).to eq(false)
      etd.proquest_submission_date = [Time.zone.today]
      expect(etd.proquest_submission_date.first).to eq(Time.zone.today)
      expect(etd.proquest_submission_date.first.instance_of?(Date)).to eq(true)
    end
  end
end
