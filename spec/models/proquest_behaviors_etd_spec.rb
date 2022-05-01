# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'
require 'workflow_setup'
include Warden::Test::Helpers
RSpec.describe Etd do
  let(:etd) { FactoryBot.create(:ready_for_proquest_submission_phd) }

  context "ProQuest submission", :perform_jobs, :clean, workflow: { admin_sets_config: 'spec/fixtures/config/emory/laney_admin_sets.yml' } do
    let(:proquest_dtd) { "#{fixture_path}/proquest/Dissertations_metadata48.dtd" }
    let(:output_xml) { "#{fixture_path}/proquest/output.xml" }
    let(:approving_user) { User.where(ppid: 'laneyadmin').first }
    let(:user) { User.where(ppid: etd.depositor).first }
    let(:ability) { ::Ability.new(user) }
    let(:upload1) { FactoryBot.create(:primary_uploaded_file, user_id: user.id) }
    let(:upload2) { FactoryBot.create(:supplementary_uploaded_file, user_id: user.id) }
    let(:attributes) { { uploaded_files: [upload1.id, upload2.id] } }
    let(:env) { Hyrax::Actors::Environment.new(etd, ability, attributes) }
    let(:terminator) { Hyrax::Actors::Terminator.new }
    let(:middleware) do
      Hyrax::DefaultMiddlewareStack.build_stack.build(terminator)
    end
    before do
      allow(CharacterizeJob).to receive(:perform_later) # There is no fits installed on travis-ci
      middleware.create(env)
      subject = Hyrax::WorkflowActionInfo.new(etd, approving_user)
      sipity_workflow_action = PowerConverter.convert_to_sipity_action("approve", scope: subject.entity.workflow) { nil }
      Hyrax::Workflow::WorkflowActionService.run(subject: subject, action: sipity_workflow_action, comment: "Preapproved")
      sipity_workflow_action = PowerConverter.convert_to_sipity_action("publish", scope: subject.entity.workflow) { nil }
      Hyrax::Workflow::WorkflowActionService.run(subject: subject, action: sipity_workflow_action, comment: "Graduated")
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
    it "returns valid required submission settings", :aggregate_failures do
      expect(etd.page_count).to eq "7"
      expect(etd.primary_pdf_file_name).to eq "joey_thesis.pdf"
      expect(etd.upload_file_id).to match(/^upload_/)
      expect(etd.xml_filename).to match(/_DATA.xml/)
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

  context "#submit_to_proquest?" do
    it "does not error on non-sipity entities", :aggregate_failures do
      expect(etd.to_sipity_entity).to be_nil
      expect { etd.submit_to_proquest? }.not_to raise_error
      expect(etd.submit_to_proquest?).to eq false
    end
    it "returns true if ETD meets submission criteria", :aggregate_failures do
      etd.stub_chain(:to_sipity_entity, :workflow_state_name).and_return("published")
      expect(etd.school).to contain_exactly("Laney Graduate School")
      expect(etd.degree).to contain_exactly("PhD")
      expect(etd.proquest_submission_date).to be_empty
      expect(etd.degree_awarded).to be_present
      expect(etd.submit_to_proquest?).to eq true
    end
    it "returns false for hidden ETDs", :aggregate_failures do
      etd.stub_chain(:to_sipity_entity, :workflow_state_name).and_return("published")
      expect(etd.submit_to_proquest?).to eq true
      etd.hidden = true
      expect(etd.submit_to_proquest?).to eq false
    end
  end

  context "Embargo codes" do
    it "transforms an embargo_length into a ProQuest embargo code", :aggregate_failures do
      etd.embargo_length = nil
      expect(etd.embargo_code).to eq 0
      etd.embargo_length = "6 months"
      expect(etd.embargo_code).to eq 1
      etd.embargo_length = "1 year"
      expect(etd.embargo_code).to eq 2
      etd.embargo_length = "2 years"
      expect(etd.embargo_code).to eq 3
      etd.embargo_length = "6 years"
      expect(etd.embargo_code).to eq 4
    end
  end

  context "abstract formatting" do
    it "transforms tinymce output into something proquest can handle", :aggregate_failures do
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
    it "transforms a language string into a ProQuest expected language code", :aggregate_failures do
      etd.language = ["English"]
      expect(etd.proquest_language).to eq "EN"
      etd.language = ["French"]
      expect(etd.proquest_language).to eq "FR"
      etd.language = ["Spanish"]
      expect(etd.proquest_language).to eq "SP"
    end
  end

  context "proquest submission type" do
    it "returns either 'masters' or 'doctoral'", :aggregate_failures do
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
    it "associates research codes", :aggregate_failures do
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
    it "records the date the etd was submitted to proquest", :aggregate_failures do
      expect(etd.proquest_submission_date).to be_empty
      etd.proquest_submission_date = [Time.zone.today]
      expect(etd.proquest_submission_date.first).to eq(Time.zone.today)
      expect(etd.proquest_submission_date.first.instance_of?(Date)).to eq(true)
    end
  end
end
