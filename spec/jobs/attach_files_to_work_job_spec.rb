require 'rails_helper'
describe AttachFilesToWorkJob do
  # This is expensive setup with many, many DB calls
  # Since the tests are only checking final state, we can run
  # this setup once and then check the resulting objects.
  before :all do
    etd = FactoryBot.create(:sample_data, title: ['RSpec AttachFilesToWorkJob examples'])
    depositing_user = User.where(ppid: etd.depositor).first
    primary = File.open("#{::Rails.root}/spec/fixtures/nasa.jpeg") do |file|
      Hyrax::UploadedFile
        .create(user: depositing_user,
                file: file,
                pcdm_use:  FileSet::PRIMARY,
                title: 'Primary ETD file',
                description: 'typically the main PDF containing the submitted Thesis or Dissertation',
                file_type: 'image')
    end
    secondary = File.open("#{::Rails.root}/spec/fixtures/magic_warrior_cat.jpg") do |file|
      Hyrax::UploadedFile
        .create(user: depositing_user,
                file: file,
                pcdm_use:  FileSet::SUPPLEMENTAL,
                title: 'cat dot jpg',
                description: 'magic warrior cat',
                file_type: 'image')
    end

    described_class.perform_now(etd, [primary, secondary])
  end

  let(:etd) { Etd.where(title: 'RSpec AttachFilesToWorkJob examples').first }
  let(:primary_file) { etd.file_sets.find { |file| file.primary? } }
  let(:supplementary_file) { etd.file_sets.find { |file| file.supplementary? } }

  it 'sets pcdm use' do
    expect(primary_file.pcdm_use).to eq FileSet::PRIMARY
  end

  it 'sets file title to work title' do
    expect(primary_file.title).to contain_exactly(*etd.title)
  end

  context 'when attaching secondary file' do
    it 'sets pcdm use' do
      expect(supplementary_file.pcdm_use).to eq FileSet::SUPPLEMENTAL
    end

    it 'sets title' do
      expect(supplementary_file.title).to contain_exactly('cat dot jpg')
    end

    it 'sets description' do
      expect(supplementary_file.description).to contain_exactly('magic warrior cat')
    end

    it 'sets file_type' do
      expect(supplementary_file.file_type).to eq 'image'
    end
  end

  context 'virus checking', :perform_jobs do
    let(:file_path) { "#{::Rails.root}/spec/fixtures/virus_checking/virus_check.txt" }
    let(:upload) do
      File.open(file_path) do |file|
        Hyrax::UploadedFile
          .create(user: User.where(ppid: etd.depositor).first,
                  file: file,
                  pcdm_use:  FileSet::PRIMARY,
                  title: 'Dummy infected file',
                  description: 'file to trigger virus scanner - we actually just force it in the "before" setup block',
                  file_type: 'text')
      end
    end

    before do
      allow(TestVirusScanner).to receive(:infected?).and_return(true)
      class_double("Hyrax::Workflow::VirusEncounteredNotification").as_stubbed_const
      allow(Hyrax::Workflow::VirusEncounteredNotification).to receive(:send_notification)
    end

    it 'notifies the depositing user and approvers when a virus is encountered' do
      described_class.perform_now(etd, [upload])
      expect(Hyrax::Workflow::VirusEncounteredNotification).to have_received(:send_notification)
    end
  end
end
