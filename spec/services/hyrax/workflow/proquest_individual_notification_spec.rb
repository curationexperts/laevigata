libdir = File.expand_path('../../../../', __FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
require 'rails_helper'

RSpec.describe Hyrax::Workflow::ProquestIndividualNotification do
  let(:etd) { FactoryBot.create(:sample_data) }
  let(:notification) { described_class.new(etd.id) }
  context "invoke with a work_id, a message and a subject" do
    it "sends notifications to the etd author" do
      user = ::User.find_by_user_key(etd.depositor)
      expect(notification.recipients.pluck(:email)).to include(user.email.downcase)
    end
  end
end
