require 'rails_helper'
# NOTE: These tests are pulled out of ./spec/service/graduation_service_spec.rb because
# the test setup for that test group takes more than 20 seconds per example.
describe GraduationService do
  let(:grad_service) { described_class.new('./spec/fixtures/registrar_sample.json') }

  describe "#extract_date" do
    it "returns an ISO date format string" do
      grad_record = { 'degree status date' => '1938-10-30' }
      expect(grad_service.extract_date(grad_record)).to eq '1938-10-30'
    end

    it "returns only the ISO date portion of the data" do
      grad_record = { 'degree status date' => "Fall '38 (1938-10-30)" }
      expect(grad_service.extract_date(grad_record)).to eq '1938-10-30'
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
        record_key = grad_service.find_registrar_match(etd_solr_doc)[1]['etd record key']
        expect(record_key).to eq 'P0000003-UCOL-LIBAS'
      end
      it 'returns verified graduation dates' do
        grad_date = grad_service.find_registrar_match(etd_solr_doc)[0]
        expect(grad_date).to eq '2017-03-16'
      end
      it 'logs match data', :aggregate_failures do
        allow(Rails.logger).to receive(:info)
        _grad_date, _grad_record = grad_service.find_registrar_match(etd_solr_doc)
        expect(Rails.logger).to have_received(:info).with(/MatchingETD/)
        expect(Rails.logger).to have_received(:info).with(/P0000003-UCOL-LIBAS/)
        expect(Rails.logger).to have_received(:info).with(/2017-03-16/)
      end
      describe "pending graduation" do
        let(:etd_solr_doc) { { 'id' => 'MatchingETD', 'depositor_ssim' => ['P0000001'], 'school_tesim' => ['Laney Graduate School'], 'degree_tesim' => ['Ph.D.'] } }
        it 'returns nil graduation date' do
          grad_date, _grad_record = grad_service.find_registrar_match(etd_solr_doc)
          expect(grad_date).to be_nil
        end
        it 'logs match data', :aggregate_failures do
          allow(Rails.logger).to receive(:info)
          _grad_date, _grad_record = grad_service.find_registrar_match(etd_solr_doc)
          expect(Rails.logger).to have_received(:info).with(/MatchingETD/)
          expect(Rails.logger).to have_received(:info).with(/P0000001-GSAS-PHD/)
          expect(Rails.logger).to have_received(:info).with(/pending/)
        end
      end
    end
    describe "for non-matches" do
      let(:etd_solr_doc) { { 'id' => 'UnmatchedETD', 'depositor_ssim' => ['P0000004'], 'school_tesim' => ['Emory College'], 'degree_tesim' => ['B.S.'] } }
      it 'logs warnings for near matches with the same PPID', :aggregate_failures do
        allow(Rails.logger).to receive(:warn)
        _grad_date, _grad_record = grad_service.find_registrar_match(etd_solr_doc)
        expect(Rails.logger).to have_received(:warn).with(/UnmatchedETD/)
        expect(Rails.logger).to have_received(:warn).with(/P0000004-UCOL-LIBAS/)
        expect(Rails.logger).to have_received(:warn).with(/P0000004-THEO-MDV \(2018-01-12\)/)
        expect(Rails.logger).to have_received(:warn).with(/P0000004-THEO-THD \(2020-05-23\)/)
      end
      it 'logs when no matches exist' do
        etd_solr_doc['depositor_ssim'] = ['P1234567']
        allow(Rails.logger).to receive(:info)
        _grad_date, _grad_record = grad_service.find_registrar_match(etd_solr_doc)
        expect(Rails.logger).to have_received(:info).with(/PPID not found in registrar data/)
      end
      it 'returns nil graduation date' do
        grad_date, _grad_record = grad_service.find_registrar_match(etd_solr_doc)
        expect(grad_date).to be_nil
      end
      it 'returns a dummy registrar record' do
        _grad_date, grad_record = grad_service.find_registrar_match(etd_solr_doc)
        expect(grad_record).to eq({ 'degree status descr' => 'Unmatched' })
      end
    end
  end
end
