require 'rails_helper'
require 'hydra/file_characterization'
include ActiveJob::TestHelper

describe ProquestJob, :clean do
  context "Laney PhD" do
    let(:etd) { FactoryBot.create(:ready_for_proquest_submission_phd, creator: ['Roberts, Bartholomew']) }
    let(:user) { User.find_by(ppid: etd.depositor) }
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
    let(:sftp_session) { spy(Net::SFTP::Session) }

    before do
      # Attach files
      perform_enqueued_jobs(except: CreateDerivativesJob) do
        allow(Hydra::FileCharacterization).to receive(:characterize).with(an_instance_of(File), "joey_thesis.pdf", :fits).and_return(file1_fits)
        # allow(Hydra::FileCharacterization).to receive(:characterize).with(an_instance_of(File), "image.tif", :fits).and_return(file2_fits)
        # We need to perform other jobs queued by AttachFilesToWorkJob to have the original PDF attached to the fileset
        AttachFilesToWorkJob.perform_now(etd, [upload1])
        # AttachFilesToWorkJob.perform_now(etd, [upload1, upload2])
      end

      # Stub workflow calls
      sipity_entity = instance_double(Sipity::Entity)
      allow(Etd).to receive(:find).with(etd.id).and_return(etd.reload)
      allow(etd).to receive(:to_sipity_entity).and_return(sipity_entity)
      allow(sipity_entity).to receive(:workflow_state_name).and_return('published')

      # Bypass workflow indexing - https://github.com/samvera/hyrax/blob/v2.9.6/app/indexers/hyrax/indexes_workflow.rb#L27
      allow(PowerConverter).to receive(:convert_to_sipity_entity).with(etd).and_return(nil)
      allow(PowerConverter).to receive(:convert_to_sipity_entity).with(sipity_entity).and_return(nil)

      # Stub SFTP to proquest
      allow(Net::SFTP).to receive(:start).and_yield(sftp_session)
    end

    context "#perform" do
      let(:grad_record) { { "home address 1" => "my place" } }
      it "persists the submission date", :aggregate_failures do
        expect(etd.submit_to_proquest?).to eq true
        expect(etd.proquest_submission_date).to be_blank

        described_class.perform_now(etd.id, grad_record, transmit: true, cleanup: true, retransmit: false)

        # It uploads to Proquest
        # - first argument is the file path, wich should match the directory configured in `config/proquest.yml`
        # - second argument is the file name, which shoud end in .zip
        expect(sftp_session).to have_received(:upload!).with(/tmp\/proquest_exports\/test/, /upload_roberts_bartholomew_\w+.zip/)

        # Includes address from registrar data
        expect(etd.export_proquest_xml(grad_record)).to match(/my place/)

        # Sets date after running ProQuest tasks
        expect(etd.reload.proquest_submission_date).to eq [Date.current]
      end
    end
  end
end
