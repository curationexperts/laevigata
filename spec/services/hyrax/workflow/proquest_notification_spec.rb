libdir = File.expand_path('../../../../', __FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
require 'rails_helper'
require 'active_fedora/cleaner'
require 'database_cleaner'

RSpec.describe Hyrax::Workflow::ProquestNotification do
  before :all do
    ActiveFedora::Cleaner.clean!
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
    w = WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/candler_admin_sets.yml", "/dev/null")
    w.setup
  end
  let(:notification) { described_class.new("subject", "message") }
  let(:admin) { FactoryBot.create(:admin) }
  context "invoke with a message and a subject" do
    it "sends notifications to the super users and proquest" do
      admin
      expect(notification.recipients.pluck(:email)).to include(ENV['PROQUEST_NOTIFICATION_EMAIL'].downcase)
    end
  end
end
