require 'rails_helper'
require 'workflow_setup'
include Warden::Test::Helpers

describe GraduationService do
  let(:grad_service) { described_class.new('./spec/fixtures/registrar_sample.json') }

  describe "#extract_date" do
    it "returns an Time class object" do
      grad_record = { 'degree status date' => '1938-10-30' }
      expect(grad_service.extract_date(grad_record)).to be_a_kind_of(Time)
      expect(grad_service.extract_date(grad_record)).to eq '1938-10-30'.to_time
    end

    it "returns only the ISO date portion of the string" do
      grad_record = { 'degree status date' => "Fall '38 (1938-10-30)" }
      expect(grad_service.extract_date(grad_record)).to eq '1938-10-30'.to_time
    end

    it "returns nil if an ISO date is not present" do
      grad_record = { 'degree status date' => " " }
      expect(grad_service.extract_date(grad_record)).to be_nil
    end

    it "returns nil if no degree status date is present" do
      grad_record = {}
      expect(grad_service.extract_date(grad_record)).to be_nil
    end

    it "handles bad input gracefully" do
      grad_record = nil
      expect(grad_service.extract_date(grad_record)).to be_nil
    end
  end

  describe "#find_registrar_match" do
    describe "for exact matches" do
      let(:etd_solr_doc) { { 'id' => 'MatchingETD', 'depositor_ssim' => ['P0000003'], 'school_tesim' => ['Emory College'], 'degree_tesim' => ['B.S.'] } }
      it 'returns the matched record' do
        record_key = grad_service.find_registrar_match(etd_solr_doc)['etd record key']
        expect(record_key).to eq 'P0000003-UCOL-LIBAS'
      end
      it 'returns graduation dates' do
        grad_record = grad_service.find_registrar_match(etd_solr_doc)
        expect(grad_record['degree status date']).to eq '2017-03-16'
      end
      it 'logs match data', :aggregate_failures do
        # allow(Rails.logger).to receive(:warn).with("GraduationService")
        expect(Rails.logger).to receive(:warn).with("GraduationService").ordered do |&block|
          expect(block.call).to eq "Running with file ./spec/fixtures/registrar_sample.json"
        end
        expect(Rails.logger).to receive(:warn).with("GraduationService").ordered do |&block|
          log_message = block.call
          expect(log_message).to include "MatchingETD"
          expect(log_message).to include "P0000003-UCOL-LIBAS"
          expect(log_message).to include "2017-03-16"
        end
        grad_service.find_registrar_match(etd_solr_doc)
      end
      describe "pending graduation" do
        let(:etd_solr_doc) { { 'id' => 'MatchingETD', 'depositor_ssim' => ['P0000001'], 'school_tesim' => ['Laney Graduate School'], 'degree_tesim' => ['Ph.D.'] } }
        it 'has no degree award date' do
          grad_record = grad_service.find_registrar_match(etd_solr_doc)
          expect(grad_record['degree status date']).to be_blank
        end
        it 'logs match data', :aggregate_failures do
          allow(Rails.logger).to receive(:warn)
          grad_service.find_registrar_match(etd_solr_doc)
          expect(Rails.logger).to have_received(:warn).with(/MatchingETD/)
          expect(Rails.logger).to have_received(:warn).with(/P0000001-GSAS-PHD/)
          expect(Rails.logger).to have_received(:warn).with(/pending/)
        end
      end
    end
    describe "for undergrad business dual majors" do
      let(:etd_solr_doc) { { 'id' => 'MatchingETD', 'depositor_ssim' => ['P0000006'], 'school_tesim' => ['Emory College'], 'degree_tesim' => ['B.B.A.'] } }
      it 'accepts UBUS as relaxed match for UCOL' do
        grad_record = grad_service.find_registrar_match(etd_solr_doc)
        expect(grad_record['degree status date']).to eq '2022-05-25'
      end
    end
    describe "for program mis-matchess" do
      let(:etd_solr_doc) { { 'id' => 'SameSchoolDifferentProgram', 'depositor_ssim' => ['P0000005'], 'school_tesim' => ['Laney Graduate School'], 'degree_tesim' => ['M.A.'] } }
      it 'logs warning and graduates', :aggregate_failures do
        allow(Rails.logger).to receive(:warn)
        _grad_record = grad_service.find_registrar_match(etd_solr_doc)
        expect(Rails.logger).to have_received(:warn).with(/SameSchoolDifferentProgram/)
        expect(Rails.logger).to have_received(:warn).with(/"registrar_key":"P0000005-GSAS-MA"/)
        expect(Rails.logger).to have_received(:warn).with(/"reconciled_key":"P0000005-GSAS-PHD"/)
        expect(Rails.logger).to have_received(:warn).with(/"grad_date":"2020-05-25"/)
      end
    end

    describe "for non-matches" do
      let(:etd_solr_doc) { { 'id' => 'UnmatchedETD', 'depositor_ssim' => ['P0000004'], 'school_tesim' => ['Emory College'], 'degree_tesim' => ['B.S.'] } }
      it 'logs warnings for near matches with the same PPID', :aggregate_failures do
        allow(Rails.logger).to receive(:warn)
        _grad_record = grad_service.find_registrar_match(etd_solr_doc)
        expect(Rails.logger).to have_received(:warn).with(/UnmatchedETD/)
        expect(Rails.logger).to have_received(:warn).with(/P0000004-UCOL-LIBAS/)
        expect(Rails.logger).to have_received(:warn).with(/P0000004-THEO-MDV/)
        expect(Rails.logger).to have_received(:warn).with(/P0000004-THEO-THD/)
      end
      it 'logs when no matches exist' do
        etd_solr_doc['depositor_ssim'] = ['P1234567']
        allow(Rails.logger).to receive(:warn)
        _grad_record = grad_service.find_registrar_match(etd_solr_doc)
        expect(Rails.logger).to have_received(:warn).with(/"status":"unmatched"/)
      end
      it 'have no degree award date' do
        grad_record = grad_service.find_registrar_match(etd_solr_doc)
        expect(grad_record['degree status date']).to be_nil
      end
      it 'returns a dummy registrar record' do
        grad_record = grad_service.find_registrar_match(etd_solr_doc)
        expect(grad_record).to include({ 'degree status descr' => 'Unmatched' })
      end
    end
  end

  describe "#run", :clean do
    let(:graduated_user) { FactoryBot.create(:graduated_user) }
    let(:nongraduated_user) { FactoryBot.create(:nongraduated_user) }
    let(:double_degree_user) { FactoryBot.create(:double_degree_user) }
    let(:approving_user) { User.where(uid: "candleradmin").first }
    let(:w) { WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/admin_sets_registrar_subset.yml", "/dev/null") }
    let(:graduated_etd) { FactoryBot.actor_create(:sample_data_undergrad, user: graduated_user) }
    let(:nongraduated_etd) { FactoryBot.actor_create(:sample_data, user: nongraduated_user) }
    # ETD for user that is graduated with one degree but is pursuing another degree with Emory
    let(:double_degree_etd) { FactoryBot.actor_create(:sample_data, degree: ["M.Div."], user: double_degree_user) }

    before do
      w.setup
      # Create and approve the graduated ETD
      subject = Hyrax::WorkflowActionInfo.new(graduated_etd, approving_user)
      sipity_workflow_action = PowerConverter.convert_to_sipity_action("approve", scope: subject.entity.workflow) { nil }
      Hyrax::Workflow::WorkflowActionService.run(subject: subject, action: sipity_workflow_action, comment: nil)
      # Create and approve the nongraduated ETD
      subject = Hyrax::WorkflowActionInfo.new(nongraduated_etd, approving_user)
      sipity_workflow_action = PowerConverter.convert_to_sipity_action("approve", scope: subject.entity.workflow) { nil }
      Hyrax::Workflow::WorkflowActionService.run(subject: subject, action: sipity_workflow_action, comment: nil)
      # Create and approve graduated ETD with a user that is in school for another degree
      subject = Hyrax::WorkflowActionInfo.new(double_degree_etd, approving_user)
      sipity_workflow_action = PowerConverter.convert_to_sipity_action("approve", scope: subject.entity.workflow) { nil }
      Hyrax::Workflow::WorkflowActionService.run(subject: subject, action: sipity_workflow_action, comment: nil)
    end

    it "finds approved etds" do
      expect(grad_service.graduation_eligible_works.map { |doc| doc['id'] }).to contain_exactly(graduated_etd.id, nongraduated_etd.id, double_degree_etd.id)
    end

    it "publishes approved & graduated etds", :aggregate_failures do
      expect(graduated_etd.to_sipity_entity.workflow_state_name).to eq "approved"
      expect(nongraduated_etd.to_sipity_entity.workflow_state_name).to eq "approved"
      expect(double_degree_etd.to_sipity_entity.workflow_state_name).to eq "approved"

      grad_service.run

      # only publishes approved etds with matching registrar data
      expect(graduated_etd.to_sipity_entity.reload.workflow_state_name).to eq "published"
      expect(nongraduated_etd.to_sipity_entity.reload.workflow_state_name).to eq "approved"
      expect(double_degree_etd.to_sipity_entity.reload.workflow_state_name).to eq "published"

      # Persists graduation date
      expect(graduated_etd.reload.degree_awarded).to eq '2017-05-18'.to_time
      expect(nongraduated_etd.reload.degree_awarded).to eq nil
      expect(double_degree_etd.reload.degree_awarded).to eq '2018-01-12'.to_time
    end

    it "passes registrar data to the GraduationJob" do
      # This address should match the address data for "P0000002-UCOL-LIBAS" in the registrar sample data
      home_address = {
        "home address 1" =>            "321 Ash Way",
        "home address city" =>         "Atlanta",
        "home address state" =>        "GA",
        "home address postal code" =>  "30301",
        "home address country code" => "USA"
      }
      allow(GraduationJob).to receive(:perform_now)

      grad_service.run

      expect(GraduationJob).to have_received(:perform_now).exactly(2).times
      expect(GraduationJob).to have_received(:perform_now).with(graduated_etd.id, a_kind_of(Time), hash_including(home_address))
    end
  end
end
