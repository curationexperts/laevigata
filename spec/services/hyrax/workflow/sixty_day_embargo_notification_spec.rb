libdir = File.expand_path('../../../../', __FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
require 'rails_helper'

RSpec.describe Hyrax::Workflow::SixtyDayEmbargoNotification, :clean do
  before do
    ActionMailer::Base.deliveries.clear
  end
  let(:user) { FactoryBot.create(:user) }
  let(:admin) { FactoryBot.create(:admin) }
  let(:etd) { FactoryBot.create(:etd, depositor: user.user_key, post_graduation_email: ["post@graduation.email"]) }
  let(:notification) { described_class.new(etd.id) }
  let(:contact) { "https://libraries.emory.edu/research/open-access-publishing/emory-repositories-policy/etd/contact" }
  context "notifications" do
    it "sends notifications to the post-graduation email address" do
      expect(notification.recipients.pluck(:email)).to include(etd.post_graduation_email.first)
    end
    it "sends notifications to the list of people in EMBARGO_NOTIFICATION_CC" do
      stub_const('ENV', ENV.to_hash.merge('EMBARGO_NOTIFICATION_CC' => admin.uid))
      expect(notification.recipients.pluck(:email)).to include(admin.email)
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
    it "links to the contact page" do
      expect(notification.message).to match(/#{contact}/)
    end
  end
end
