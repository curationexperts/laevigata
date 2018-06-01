require 'rails_helper'
require 'workflow_setup'
include Warden::Test::Helpers

describe EmbargoExpirationService, :clean do
  context "rake task" do
    let(:expiration_service_instance) { instance_double(described_class) }
    it "sets the default date to today if no value is passed" do
      allow(described_class).to receive(:new).and_return(expiration_service_instance)
      allow(expiration_service_instance).to receive(:run)
      described_class.run(nil)
      expect(described_class).to have_received(:new).with(Time.zone.today)
    end
    it "sets the run date if passed" do
      allow(described_class).to receive(:new).and_return(expiration_service_instance)
      allow(expiration_service_instance).to receive(:run)
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
  context "#send_sixty_day_notifications" do
    let(:etd) { FactoryBot.create(:sixty_day_expiration) }
    let(:service) { described_class.new(Time.zone.today) }
    it "finds all ETDs whose embargo will expire in 60 days" do
      expect(etd.embargo_release_date).to eq(Time.zone.today + 60.days)
      expect(service.find_expirations(60).map(&:id)).to contain_exactly(etd.id)
    end
    it "sends a notification for each one" do
      allow(Hyrax::Workflow::SixtyDayEmbargoNotification).to receive(:send_notification)
      expect(etd.embargo_release_date).to eq(Time.zone.today + 60.days)
      service.send_sixty_day_notifications
      expect(Hyrax::Workflow::SixtyDayEmbargoNotification).to have_received(:send_notification)
    end
  end
  context "#send_seven_day_notifications" do
    let(:etd) { FactoryBot.create(:seven_day_expiration) }
    let(:service) { described_class.new(Time.zone.today) }
    it "finds all ETDs whose embargo will expire in 7 days" do
      expect(etd.embargo_release_date).to eq(Time.zone.today + 7.days)
      expect(service.find_expirations(7).map(&:id)).to contain_exactly(etd.id)
    end
    it "sends a notification for each one" do
      allow(Hyrax::Workflow::SevenDayEmbargoNotification).to receive(:send_notification)
      expect(etd.embargo_release_date).to eq(Time.zone.today + 7.days)
      service.send_seven_day_notifications
      expect(Hyrax::Workflow::SevenDayEmbargoNotification).to have_received(:send_notification)
    end
  end

  # Note: It is illegal to make an embargo whose expiration is today,
  # so both the test embargoes and the expiration service are invoked
  # for "tomorrow"
  context "#send_today_notifications" do
    let(:etd) { FactoryBot.create(:tomorrow_expiration) }
    let(:service) { described_class.new(Time.zone.tomorrow) }
    it "finds all ETDs whose embargo will expire the same day as the service's invocation date" do
      expect(etd.embargo_release_date).to eq(Time.zone.tomorrow)
      expect(service.find_expirations(0).map(&:id)).to contain_exactly(etd.id)
    end
    it "sends a notification for each one" do
      allow(Hyrax::Workflow::TodayEmbargoNotification).to receive(:send_notification)
      expect(etd.embargo_release_date).to eq(Time.zone.tomorrow)
      service.send_today_notifications
      expect(Hyrax::Workflow::TodayEmbargoNotification).to have_received(:send_notification)
    end
  end

  context "#expire_embargoes" do
    let(:etd) { FactoryBot.create(:tomorrow_expiration) }
    let(:service) { described_class.new(Time.zone.tomorrow) }
    it "removes the embargo for each object whose expiration date has been reached" do
      expect(etd.embargo_release_date).to eq(Time.zone.tomorrow)
      expect(etd.under_embargo?).to eq true
      service.expire_embargoes
      etd.reload
      # etd.embargo_history should have a log message like this:
      # => "An active embargo was deactivated on 2014-06-13.
      # Its release date was 2014-06-15T05:00:00+00:00.
      # Visibility during embargo was authenticated and intended visibility after embargo was open"
      expect(etd.embargo_history.last).to match(/deactivated/)
      expect(etd.under_embargo?).to eq false
    end
  end

  # Note: It is illegal to make an embargo whose expiration is today,
  # so both the test embargoes and the expiration service are invoked
  # for "tomorrow"
  context "#send_summary_report" do
    let(:etd1) do
      FactoryBot.create(
        :sixty_day_expiration,
        embargo: FactoryBot.create(:embargo, embargo_release_date: (Time.zone.tomorrow + 60.days))
      )
    end
    let(:etd2) do
      FactoryBot.create(
        :seven_day_expiration,
        embargo: FactoryBot.create(:embargo, embargo_release_date: (Time.zone.tomorrow + 7.days))
      )
    end
    let(:etd3) do
      FactoryBot.create(:tomorrow_expiration)
    end
    let(:service) { described_class.new(Time.zone.tomorrow) }
    before do
      etd1
      etd2
      etd3
      allow(Hyrax::Workflow::SixtyDayEmbargoNotification).to receive(:send_notification)
      allow(Hyrax::Workflow::SevenDayEmbargoNotification).to receive(:send_notification)
      allow(Hyrax::Workflow::TodayEmbargoNotification).to receive(:send_notification)
      allow(Hyrax::Workflow::EmbargoSummaryReportNotification).to receive(:send_notification)
    end
    it "formats a work for inclusion in the summary report" do
      formatted_work = service.format_for_summary_report(etd1)
      expect(formatted_work).to match(/#{etd1.creator.first}/)
      expect(formatted_work).to match(/#{etd1.title.first}/)
      expect(formatted_work).to match(/#{etd1.id}/)
    end
    it "creates a summary report" do
      service.run
      expect(Hyrax::Workflow::SixtyDayEmbargoNotification).to have_received(:send_notification)
      expect(Hyrax::Workflow::SevenDayEmbargoNotification).to have_received(:send_notification)
      expect(Hyrax::Workflow::TodayEmbargoNotification).to have_received(:send_notification)
      expect(service.summary_report).to match(/#{etd1.id}/)
      expect(service.summary_report).to match(/#{etd2.id}/)
      expect(service.summary_report).to match(/#{etd3.id}/)
    end
    it "sends the summary report" do
      service.run
      expect(Hyrax::Workflow::EmbargoSummaryReportNotification).to have_received(:send_notification).with(service.summary_report_subject, service.summary_report)
    end
  end
end
