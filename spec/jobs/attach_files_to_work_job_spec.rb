require 'rails_helper'
describe AttachFilesToWorkJob do
  let(:depositing_user) { User.where(ppid: etd.depositor).first }
  let(:etd) { FactoryBot.create(:sample_data) }
  context 'virus checking' do
    before do
      # Comment out these Clamby lines, and the ones in rails_helper.rb to really test virus scanning
      class_double("Clamby").as_stubbed_const
      allow(Clamby).to receive(:virus?).and_return(true)
      class_double("Hyrax::Workflow::VirusEncounteredNotification").as_stubbed_const
      allow(Hyrax::Workflow::VirusEncounteredNotification).to receive(:send_notification)
      virus_file_path = "#{::Rails.root}/spec/fixtures/virus_checking/virus_check.txt"
      upload = File.open(virus_file_path) do |virus_file|
        Hyrax::UploadedFile.create(user: depositing_user, file: virus_file, pcdm_use: 'primary')
      end
      described_class.perform_now(etd, [upload])
    end
    it 'notifies the depositing user and approvers when a virus is encountered' do
      expect(Hyrax::Workflow::VirusEncounteredNotification).to have_received(:send_notification)
    end
  end
end
