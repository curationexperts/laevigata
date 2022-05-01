require 'rails_helper'
require 'workflow_setup'
require 'hydra/file_characterization'
include Warden::Test::Helpers
include ActiveJob::TestHelper

describe ProquestJob, :clean do
  context "Laney PhD" do
    let(:w) { WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/laney_admin_sets.yml", "/dev/null") }
    let(:etd) { FactoryBot.create(:ready_for_proquest_submission_phd) }
    let(:user) { User.where(ppid: etd.depositor).first }
    let(:ability) { ::Ability.new(user) }
    let(:file1_path) { "#{::Rails.root}/spec/fixtures/joey/joey_thesis.pdf" }
    let(:file1_fits) { "#{fixture_path}/spec/fixtures/joey/joey_thesis.fits.xml" }
    let(:file2_path) { "#{::Rails.root}/spec/fixtures/miranda/image.tif" }
    let(:file2_fits) { "#{fixture_path}/spec/fixtures/miranda.fits.xml" }
    let(:upload1) do
      File.open(file1_path) do |file1|
        Hyrax::UploadedFile.create(user: user, file: file1, pcdm_use: FileSet::PRIMARY)
      end
    end
    let(:upload2) do
      File.open(file2_path) do |file2|
        Hyrax::UploadedFile.create(
          user: user,
          file: file2,
          pcdm_use: FileSet::SUPPLEMENTARY,
          description: 'Description of the supplementary file',
          file_type: 'Image'
        )
      end
    end
    let(:attributes_for_actor) { { uploaded_files: [upload1.id, upload2.id] } }
    let(:approving_user) { User.where(ppid: 'laneyadmin').first }
    before do
      # allow(CharacterizeJob).to receive(:perform_later) # There is no fits installed in CI environment
      # Stub out characterization to avoid system calls.
      # Characterization needs to occur for files to be properly attached to file_sets.
      allow(Hydra::FileCharacterization).to receive(:characterize).with(an_instance_of(File), "joey_thesis.pdf", :fits).and_return(file1_fits)
      allow(Hydra::FileCharacterization).to receive(:characterize).with(an_instance_of(File), "image.tif", :fits).and_return(file2_fits)
      w.setup
      env = Hyrax::Actors::Environment.new(etd, ability, attributes_for_actor)
      middleware = Hyrax::DefaultMiddlewareStack.build_stack.build(Hyrax::Actors::Terminator.new)
      middleware.create(env)
      perform_enqueued_jobs(except: CreateDerivativesJob) do
        # We need to perform queued jobs to have the actual PDF attached to the fileset after characterization
        AttachFilesToWorkJob.perform_now(etd, [upload1, upload2])
      end
      subject = Hyrax::WorkflowActionInfo.new(etd, approving_user)
      sipity_workflow_action = PowerConverter.convert_to_sipity_action("approve", scope: subject.entity.workflow) { nil }
      Hyrax::Workflow::WorkflowActionService.run(subject: subject, action: sipity_workflow_action, comment: "Preapproved")
      sipity_workflow_action = PowerConverter.convert_to_sipity_action("publish", scope: subject.entity.workflow) { nil }
      Hyrax::Workflow::WorkflowActionService.run(subject: subject, action: sipity_workflow_action, comment: "Graduated")
      etd.state = Vocab::FedoraResourceStatus.active # simulates GraduationJob
      etd.save
    end
    context "#perform" do
      it "persists the submission date", :aggregate_failures do
        expect(etd.submit_to_proquest?).to eq true
        expect(etd.reload.proquest_submission_date).not_to be_present
        described_class.perform_now(etd.id, transmit: false, cleanup: true, retransmit: true)
        expect(etd.reload.proquest_submission_date).to eq [Date.current]
      end
    end
  end
end
