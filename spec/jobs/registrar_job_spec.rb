require 'rails_helper'

describe RegistrarJob do
  let(:registrar_feed) { FactoryBot.create(:registrar_feed) }

  context 'processing RegistrarFeed' do
    it 'changes status to "queued" when enqueued' do
      expect(registrar_feed.status).to eq 'initialized'
      described_class.perform_later(registrar_feed)
      expect(registrar_feed.status).to eq 'queued'
    end

    it 'calls the GraduationService' do
      report_double = double
      allow(report_double).to receive(:filename).and_return Rails.root.join('spec', 'fixtures', 'registrar_feeds', 'graduation_report.csv')
      service_double = double
      allow(service_double).to receive(:graduation_report).and_return report_double
      allow(GraduationService).to receive(:run).and_return service_double

      described_class.perform_now(registrar_feed)
      expect(GraduationService).to have_received(:run)
    end

    it 'changes status to "completed" on success' do
      report_double = double
      allow(report_double).to receive(:filename).and_return Rails.root.join('spec', 'fixtures', 'registrar_feeds', 'graduation_report.csv')
      service_double = double
      allow(service_double).to receive(:graduation_report).and_return report_double
      allow(GraduationService).to receive(:run).and_return service_double

      described_class.perform_now(registrar_feed)
      expect(registrar_feed.status).to eq 'completed'
    end

    it 'attaches the graduation report' do
      expect(registrar_feed.report).not_to be_attached
      described_class.perform_now(registrar_feed)
      expect(registrar_feed.report).to be_attached
    end

    it 'sets status to "errored" on exceptions' do
      allow(GraduationService).to receive(:run).and_raise('InvalidDatafile')
      described_class.perform_now(registrar_feed)
      expect(registrar_feed.status).to eq 'errored'
    end
  end
end
