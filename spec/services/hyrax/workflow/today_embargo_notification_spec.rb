libdir = File.expand_path('../../../../', __FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
require 'rails_helper'

RSpec.describe Hyrax::Workflow::TodayEmbargoNotification, :clean do
  before do
    ActionMailer::Base.deliveries.clear
  end
  let(:user) { FactoryBot.create(:user) }
  let(:etd) { FactoryBot.create(:etd, depositor: user.user_key, post_graduation_email: ["post@graduation.email"]) }
  let(:notification) { described_class.new(etd.id) }
  context "notifications" do
    it "sends notifications to the post-graduation email address" do
      expect(notification.recipients.pluck(:email)).to include(etd.post_graduation_email.first)
    end
    it "can be invoked at the Class level" do
      n = described_class.send_notification(etd.id)
      expect(n).to be_instance_of(described_class)
      expect(ActionMailer::Base.deliveries.map(&:subject)).to include(n.subject)
    end
    it "doesn't truncate the message" do
      expect(notification.message).to match(/Dear #{user.display_name}/)
      expect(notification.message).to match(/#{etd.title.first}/)
      expect(notification.message).to match(/proquest.com/)
    end
  end
end
