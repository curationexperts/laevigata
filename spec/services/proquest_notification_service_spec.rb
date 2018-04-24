require 'rails_helper'
require 'workflow_setup'
include Warden::Test::Helpers

describe ProquestNotificationService do
  before do
    Etd.delete_all
  end
  context "rake task" do
    let(:notification_service_instance) { instance_double(described_class) }
    it "sets the default date to today if no value is passed" do
      allow(described_class).to receive(:new).and_return(notification_service_instance)
      allow(notification_service_instance).to receive(:run)
      described_class.run(nil)
      expect(described_class).to have_received(:new).with(Time.zone.today)
    end
    it "sets the run date if passed" do
      allow(described_class).to receive(:new).and_return(notification_service_instance)
      allow(notification_service_instance).to receive(:run)
      described_class.run("2018-01-28")
      expect(described_class).to have_received(:new).with(Date.parse("2018-01-28"))
    end
  end
  context "date formatting" do
    let(:service) { described_class.new(Time.zone.today) }
    it "formats a date so it can be used in a solr query" do
      date = Date.parse('2017-07-27')
      expect(service.solrize_date(date)).to eq "2017-07-27T00:00:00Z"
    end
    it "formats single digit days correctly" do
      date = Date.parse('2017-08-04')
      expect(service.solrize_date(date)).to eq "2017-08-04T00:00:00Z"
    end
  end

  # Email proquest and tell them we uploaded some files for them to process
  context "#proquest_notifications today" do
    let(:etd) { FactoryBot.create(:ready_for_proquest_submission_phd, proquest_submission_date: [Time.zone.today]) }
    let(:service) { described_class.new(Time.zone.today) }
    it "finds all ETDs that were transmitted to proquest today" do
      expect(etd.proquest_submission_date.first).to eq(Time.zone.today)
      expect(service.notification_list.map(&:id)).to contain_exactly(etd.id)
    end
  end
  context "#proquest_notifications for arbitrary date" do
    let(:arbitrary_date) { Time.zone.today - 5.days }
    let(:etd) { FactoryBot.create(:ready_for_proquest_submission_phd, proquest_submission_date: [arbitrary_date]) }
    let(:service) { described_class.new(arbitrary_date) }
    it "finds all ETDs that were transmitted to proquest on an arbitrary date" do
      etd.proquest_submission_date = [arbitrary_date]
      expect(etd.proquest_submission_date.first).to eq(arbitrary_date)
      expect(service.notification_list.map(&:id)).to contain_exactly(etd.id)
    end
  end
end
