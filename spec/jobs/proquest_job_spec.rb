require 'rails_helper'
require 'active_fedora/cleaner'
require 'workflow_setup'
include Warden::Test::Helpers

describe ProquestJob do
  context "Laney PhD" do
    let(:w) { WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/laney_admin_sets.yml", "/dev/null") }
    let(:etd) { FactoryGirl.create(:ready_for_proquest_submission_phd) }
    let(:user) { User.where(ppid: etd.depositor).first }
    let(:ability) { ::Ability.new(user) }
    let(:file1_path) { "#{::Rails.root}/spec/fixtures/joey/joey_thesis.pdf" }
    let(:file2_path) { "#{::Rails.root}/spec/fixtures/miranda/image.tif" }
    let(:upload1) do
      File.open(file1_path) do |file1|
        Hyrax::UploadedFile.create(user: user, file: file1, pcdm_use: 'primary')
      end
    end
    let(:upload2) do
      File.open(file2_path) do |file2|
        Hyrax::UploadedFile.create(
          user: user,
          file: file2,
          pcdm_use: 'supplementary',
          description: 'Description of the supplementary file',
          file_type: 'Image'
        )
      end
    end
    let(:actor) { Hyrax::CurationConcern.actor(etd, ability) }
    let(:attributes_for_actor) { { uploaded_files: [upload1.id, upload2.id] } }
    let(:approving_user) { User.where(ppid: 'laneyadmin').first }
    before do
      allow(CharacterizeJob).to receive(:perform_later) # There is no fits installed on travis-ci
      ActiveFedora::Cleaner.clean!
      w.setup
      actor.create(attributes_for_actor)
      subject = Hyrax::WorkflowActionInfo.new(etd, approving_user)
      sipity_workflow_action = PowerConverter.convert_to_sipity_action("approve", scope: subject.entity.workflow) { nil }
      Hyrax::Workflow::WorkflowActionService.run(subject: subject, action: sipity_workflow_action, comment: "Preapproved")
      etd.state = Vocab::FedoraResourceStatus.active # simulates GraduationJob
      etd.save
    end
    it "checks that this work meets the criteria for ProQuest PhD submission" do
      expect(etd.school).to contain_exactly("Laney Graduate School")
      expect(etd.degree).to contain_exactly("PhD")
      expect(etd.to_sipity_entity.workflow_state_name).to eq "approved"
      expect(etd.degree_awarded).to be_instance_of(Date)
      expect(described_class.submit_to_proquest?(etd)).to eq true
    end
  end
end
