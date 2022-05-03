require 'rails_helper'
require 'workflow_setup'
require 'hydra/file_characterization'
include Warden::Test::Helpers
include ActiveJob::TestHelper

describe ProquestJob, :clean do
  context "Laney PhD" do
    let(:w) { WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/laney_admin_sets.yml", "/dev/null") }
    let(:etd) { FactoryBot.build(:ready_for_proquest_submission_phd) }
    let(:user) { User.find_by(ppid: etd.depositor) }
    let(:ability) { ::Ability.new(user) }
    let(:file1_path) { "#{::Rails.root}/spec/fixtures/joey/joey_thesis.pdf" }
    let(:file1_fits) { "#{fixture_path}/spec/fixtures/joey/joey_thesis.fits.xml" }
    let(:upload1) do
      File.open(file1_path) do |file1|
        Hyrax::UploadedFile.create(user: user, file: file1, pcdm_use: FileSet::PRIMARY)
      end
    end
    # TODO: add tests that actually check secondary files are included in Proquest submission
    # let(:file2_path) { "#{::Rails.root}/spec/fixtures/miranda/image.tif" }
    # let(:file2_fits) { "#{fixture_path}/spec/fixtures/miranda.fits.xml" }
    # let(:upload2) do
    #   File.open(file2_path) do |file2|
    #     Hyrax::UploadedFile.create(
    #       user: user,
    #       file: file2,
    #       pcdm_use: FileSet::SUPPLEMENTARY,
    #       description: 'Description of the supplementary file',
    #       file_type: 'Image'
    #     )
    #   end
    # end
    # let(:attributes_for_actor) { { uploaded_files: [upload1.id, upload2.id] } }
    let(:attributes_for_actor) { { uploaded_files: [upload1.id] } }
    let(:approving_user) { User.where(ppid: 'laneyadmin').first }
    before do
      # Stub out Etd persistence calls
      etd.save
      allow(Etd).to receive(:find).and_return(etd)
      allow(etd).to receive(:save!).and_return(etd)
      allow(etd).to receive(:reload).and_return(etd)

      env = Hyrax::Actors::Environment.new(etd, ability, attributes_for_actor)
      stack = Hyrax::DefaultMiddlewareStack.build_stack
      # Bypass AdminSet and Workflow processing to speed up tests
      stack.middlewares.delete Hyrax::Actors::DefaultAdminSetActor
      stack.middlewares.delete Hyrax::Actors::InitializeWorkflowActor
      middleware = stack.build(Hyrax::Actors::Terminator.new)
      middleware.create(env)
      perform_enqueued_jobs(except: CreateDerivativesJob) do
        allow(Hydra::FileCharacterization).to receive(:characterize).with(an_instance_of(File), "joey_thesis.pdf", :fits).and_return(file1_fits)
        # allow(Hydra::FileCharacterization).to receive(:characterize).with(an_instance_of(File), "image.tif", :fits).and_return(file2_fits)
        # We need to perform other jobs queued by AttachFilesToWorkJob to have the original PDF attached to the fileset
        AttachFilesToWorkJob.perform_now(etd, [upload1])
        # AttachFilesToWorkJob.perform_now(etd, [upload1, upload2])
      end
      sipity_entity = double(Sipity::Entity)
      allow(sipity_entity).to receive(:workflow_state_name).and_return('published')
      allow(etd).to receive(:to_sipity_entity).and_return(sipity_entity)
    end
    context "#perform" do
      let(:grad_record) { { "home address 1" => "my place" } }
      it "persists the submission date", :aggregate_failures do
        allow(etd).to receive(:save).and_return(true)

        expect(etd.submit_to_proquest?).to eq true
        expect(etd.reload.proquest_submission_date).not_to be_present
        described_class.perform_now(etd.id, grad_record, transmit: false, cleanup: true, retransmit: false)

        # Includes address from registrar data
        expect(etd.export_proquest_xml(grad_record)).to match(/my place/)

        # Sets date after running ProQuest tasks
        expect(etd.reload.proquest_submission_date).to eq [Date.current]
      end
    end
  end
end
