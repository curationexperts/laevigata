libdir = File.expand_path('../../../../', __FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
require 'rails_helper'
require 'active_fedora/cleaner'
require 'workflow_setup'
require 'database_cleaner'

RSpec.describe Hyrax::Workflow::EmbargoSummaryReportNotification, :clean do
  before :all do
    w = WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/candler_admin_sets.yml", "/dev/null")
    w.setup
  end
  let(:notification) { described_class.new("subject", "message") }
  context "invoke with a message and a subject" do
    it "sends notifications to the super users and no one else" do
      expect(notification.recipients.pluck(:uid)).to contain_exactly("superman001", "wonderwoman001", "tezprox")
    end
  end
end
