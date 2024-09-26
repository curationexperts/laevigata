libdir = File.expand_path('../../../../', __FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
require 'rails_helper'

RSpec.describe Hyrax::Workflow::ProquestNotification, :clean do
  before do
    w = WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/candler_admin_sets.yml", "/dev/null")
    w.setup
  end
  let(:notification) { described_class.new("subject", "message") }
  let(:admin) { FactoryBot.create(:admin) }
  context "invoke with a message and a subject" do
    it "sends notifications to the super users and proquest" do
      admin
      expect(notification.recipients.pluck(:email)).to include(admin.email)
    end
  end
end
