require 'rails_helper'
require 'active_fedora/cleaner'
require 'workflow_setup'
include Warden::Test::Helpers

describe GraduationService do
  let(:depositing_user) { User.where(ppid: etd.depositor).first }
  let(:approving_user) { User.where(uid: "candleradmin").first }
  let(:w) { WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/candler_admin_sets.yml", "/dev/null") }
  let(:etd) { FactoryGirl.create(:sample_data, school: ["Candler School of Theology"]) }
  before do
    ActiveFedora::Cleaner.clean!
    w.setup
    actor = Hyrax::CurationConcern.actor(etd, ::Ability.new(depositing_user))
    actor.create({})
    # The approving user marks the etd as approved
    subject = Hyrax::WorkflowActionInfo.new(etd, approving_user)
    sipity_workflow_action = PowerConverter.convert_to_sipity_action("approve", scope: subject.entity.workflow) { nil }
    Hyrax::Workflow::WorkflowActionService.run(subject: subject, action: sipity_workflow_action, comment: nil)
    expect(etd.to_sipity_entity.reload.workflow_state_name).to eq "approved"
  end
  describe "#check_for_new_graduates" do
    it "finds all works in an approved state that do not yet have a degree_awarded value" do
      expect(described_class.graduation_eligible_works.map(&:id)).to contain_exactly(etd.id)
    end
    it "checks the graduation status for a given work" do
      expect(described_class.check_degree_status(etd)).to eq Time.zone.today
    end
    it "checks for new graduates" do
      allow(GraduationJob).to receive(:perform_later)
      described_class.check_for_new_graduates
      expect(GraduationJob).to have_received(:perform_later)
    end
  end
end
