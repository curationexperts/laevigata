require 'rails_helper'
describe AttachFilesToWorkJob do
  let(:depositing_user) { User.where(ppid: etd.depositor).first }
  let(:etd) { FactoryBot.create(:sample_data) }
  let(:file_path) { "#{::Rails.root}/spec/fixtures/magic_warrior_cat.jpg" }
  let(:pcdm_use)  { 'primary' }

  let(:upload) do
    File.open(file_path) do |file|
      Hyrax::UploadedFile
        .create(user: depositing_user,
                file: file,
                pcdm_use: pcdm_use,
                title: 'cat dot jpg',
                description: 'magic warrior cat',
                file_type: 'image')
    end
  end

  it 'sets pcdm use' do
    described_class.perform_now(etd, [upload])
    expect(etd.file_sets.first.reload.pcdm_use).to eq pcdm_use
  end

  it 'sets file title to work title' do
    described_class.perform_now(etd, [upload])
    expect(etd.file_sets.first.reload.title).to contain_exactly(*etd.title)
  end

  context 'when attaching secondary file' do
    let(:pcdm_use) { 'secondary' }

    it 'sets pcdm use' do
      described_class.perform_now(etd, [upload])
      expect(etd.file_sets.first.reload.pcdm_use).to eq pcdm_use
    end

    it 'sets title' do
      described_class.perform_now(etd, [upload])
      expect(etd.file_sets.first.reload.title).to contain_exactly(upload.title)
    end

    it 'sets description' do
      described_class.perform_now(etd, [upload])
      expect(etd.file_sets.first.reload.description).to contain_exactly(upload.description)
    end

    it 'sets file_type' do
      described_class.perform_now(etd, [upload])
      expect(etd.file_sets.first.reload.file_type).to eq upload.file_type
    end
  end

  context 'virus checking', :perform_jobs do
    let(:file_path) { "#{::Rails.root}/spec/fixtures/virus_checking/virus_check.txt" }

    before do
      # Comment out these Clamby lines, and the ones in rails_helper.rb to really test virus scanning
      class_double("Clamby").as_stubbed_const
      allow(Clamby).to receive(:virus?).and_return(true)
      class_double("Hyrax::Workflow::VirusEncounteredNotification").as_stubbed_const
      allow(Hyrax::Workflow::VirusEncounteredNotification).to receive(:send_notification)
    end

    it 'notifies the depositing user and approvers when a virus is encountered' do
      described_class.perform_now(etd, [upload])
      expect(Hyrax::Workflow::VirusEncounteredNotification).to have_received(:send_notification)
    end
  end
end
