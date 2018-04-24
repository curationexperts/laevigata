require 'rails_helper'
require 'workflow_setup'
include Warden::Test::Helpers

describe GraduationService, :clean do
  let(:graduated_user) { FactoryBot.create(:graduated_user) }
  let(:nongraduated_user) { FactoryBot.create(:nongraduated_user) }
  let(:approving_user) { User.where(uid: "candleradmin").first }
  let(:w) { WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/candler_admin_sets.yml", "/dev/null") }
  let(:graduated_etd) { FactoryBot.create(:sample_data) }
  let(:nongraduated_etd) { FactoryBot.create(:sample_data) }
  before do
    w.setup
    # Create and approve the graduated ETD
    actor = Hyrax::CurationConcern.actor(graduated_etd, ::Ability.new(graduated_user))
    actor.create({})
    subject = Hyrax::WorkflowActionInfo.new(graduated_etd, approving_user)
    sipity_workflow_action = PowerConverter.convert_to_sipity_action("approve", scope: subject.entity.workflow) { nil }
    Hyrax::Workflow::WorkflowActionService.run(subject: subject, action: sipity_workflow_action, comment: nil)
    expect(graduated_etd.to_sipity_entity.reload.workflow_state_name).to eq "approved"
    # Create and approve the nongraduated ETD
    actor = Hyrax::CurationConcern.actor(nongraduated_etd, ::Ability.new(nongraduated_user))
    actor.create({})
    subject = Hyrax::WorkflowActionInfo.new(nongraduated_etd, approving_user)
    sipity_workflow_action = PowerConverter.convert_to_sipity_action("approve", scope: subject.entity.workflow) { nil }
    Hyrax::Workflow::WorkflowActionService.run(subject: subject, action: sipity_workflow_action, comment: nil)
    expect(nongraduated_etd.to_sipity_entity.reload.workflow_state_name).to eq "approved"
  end
  describe "#run" do
    it "finds all works in an approved state that do not yet have a degree_awarded value" do
      described_class.load_data('./spec/fixtures/registrar_sample.json')
      expect(described_class.graduation_eligible_works.map(&:id)).to contain_exactly(graduated_etd.id, nongraduated_etd.id)
      described_class.remove_instance_variable(:@registrar_data)
    end
    it "checks the graduation status for a given work" do
      described_class.load_data('./spec/fixtures/registrar_sample.json')
      expect(described_class.check_degree_status(graduated_etd)).to eq Date.new(2017, 5, 18)
      expect(described_class.check_degree_status(nongraduated_etd)).to eq false
      described_class.remove_instance_variable(:@registrar_data)
    end
    it "checks for new graduates" do
      allow(GraduationJob).to receive(:perform_later)
      described_class.run('./spec/fixtures/registrar_sample.json')
      expect(GraduationJob).to have_received(:perform_later)
    end
  end
end
