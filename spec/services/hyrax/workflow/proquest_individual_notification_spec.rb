require 'rails_helper'

RSpec.describe Hyrax::Workflow::ProquestIndividualNotification do
  let(:notification_owner) { spy(User) }
  let(:logger) { spy(Rails.logger) }
  let(:etd) { FactoryBot.build(:etd, id: 'test_etd', depositor: depositor.user_key, title: ['Delightful Dissertation']) }
  let(:depositor) { FactoryBot.build(:user, ppid: 'fake_user_key') }

  before do
    # Stub WorkflowSetup::NOTIFICATION_OWNER
    allow(User).to receive(:find_or_create_by).with(uid: WorkflowSetup::NOTIFICATION_OWNER).and_return(notification_owner)

    # Stub depositor persistence
    allow(User).to receive(:find_by_user_key).with(depositor.ppid).and_return(depositor)

    # Stub ETD persistence
    allow(Etd).to receive(:find).with(etd.id).and_return(etd)

    # Stub logging
    allow(Rails).to receive(:logger).and_return(logger)
  end

  describe '.send_notification' do
    it 'is a class method that notifies the depositor' do
      described_class.send_notification(etd.id)
      expect(notification_owner)
        .to have_received(:send_message)
                                      .with(depositor,
                                            /submitted to ProQuest, for publication/,
                                            /Your work, Delightful Dissertation, has been submitted to ProQuest./)
    end

    it 'logs the notifications' do
      described_class.send_notification(etd.id)
      expect(logger).to have_received(:warn)
    end
  end
end
