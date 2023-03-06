# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Do not send email to blacklisted addresses', :clean, integration: true, type: :system do
  before do
    ActionMailer::Base.deliveries.clear
  end
  context 'on the blacklist' do
    let(:user) { FactoryBot.create(:user, email: 'tezprox@emory.edu') }
    let(:etd) { FactoryBot.create(:sample_data, depositor: user.user_key, post_graduation_email: ['tezprox@emory.edu']) }
    scenario "does not send an email" do
      n = Hyrax::Workflow::SevenDayEmbargoNotification.send_notification(etd.id)
      expect(ActionMailer::Base.deliveries.map(&:subject)).not_to include(n.subject)
    end
  end

  context 'not on the blacklist' do
    let(:user2) { FactoryBot.create(:user) }
    let(:etd2) { FactoryBot.create(:sample_data, depositor: user2.user_key, post_graduation_email: ['goodemail@emory.edu']) }
    scenario "does send an email" do
      n = Hyrax::Workflow::SevenDayEmbargoNotification.send_notification(etd2.id)
      expect(ActionMailer::Base.deliveries.map(&:subject)).to include(n.subject)
    end
  end
end
