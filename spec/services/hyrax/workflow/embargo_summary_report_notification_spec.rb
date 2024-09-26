require 'rails_helper'

RSpec.describe Hyrax::Workflow::EmbargoSummaryReportNotification do
  let(:admins) { FactoryBot.build_list(:admin, 1) }
  let(:notification_owner) { spy(User) }
  let(:logger) { spy(Rails.logger) }

  before do
    # Stub Role :admin
    role = double(Role)
    allow(Role).to receive(:find_by).with(name: 'admin').and_return(role)
    allow(role).to receive(:users).and_return(admins)

    # Stub WorkflowSetup::NOTIFICATION_OWNER
    allow(User).to receive(:find_or_create_by).with(uid: WorkflowSetup::NOTIFICATION_OWNER).and_return(notification_owner)

    # Stub logging
    allow(Rails).to receive(:logger).and_return(logger)
  end

  describe '.send_notification' do
    it 'is a class method that notifies super admins' do
      described_class.send_notification('subject', 'message')
      expect(notification_owner).to have_received(:send_message).with(admins.first, 'message', 'subject')
    end

    it 'logs the notifications' do
      described_class.send_notification('subject', 'message')
      expect(logger).to have_received(:warn).twice
    end
  end

  describe 'with multiple super users' do
    let(:notification) { described_class.new("subject", "message") }
    let(:admins) { FactoryBot.build_list(:admin, 3) }

    it 'sends to each super user' do
      expect(notification.recipients.pluck(:uid)).to match_array(admins.map(&:uid))
    end
  end
end
