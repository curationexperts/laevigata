require 'rails_helper'

RSpec.describe Importer::AsynchronousRecordImporter do
  subject(:importer) do
    described_class.new(error_stream: error_stream, info_stream: info_stream)
  end

  let(:error_stream) { Importer::SerializableStream.new(ActiveJob::Base.logger) }
  let(:info_stream)  { Importer::SerializableStream.new(ActiveJob::Base.logger) }
  let(:mapper)       { Importer::MigrationMapper.new }
  let(:pid)          { '1' }

  let(:record) { Darlingtonia::InputRecord.from(metadata: pid, mapper: mapper) }

  it do
    is_expected.to have_attributes(error_stream: error_stream,
                                   info_stream:  info_stream)
  end

  describe '#import' do
    before { ActiveJob::Base.queue_adapter = :test }

    it 'serializes streams successfully for queue' do
      expect { importer.import(record: record) }
        .to have_enqueued_job(Importer::MigrationImportJob)
              .with(record.mapper.pid,
                    record.mapper.source_host,
                    an_instance_of(importer.error_stream.class),
                    an_instance_of(importer.info_stream.class))
    end

    context 'when jobs are run' do
      let(:mapper)           { Importer::MigrationMapper.new(source_host: stubbed_host) }
      let(:foxml)            { File.read("#{fixture_path}/import/digital_object.xml") }
      let(:author_id)        { 'emory:194h4' }
      let(:author_foxml)     { File.read("#{fixture_path}/import/author_info.xml") }
      let(:file_id)          { 'emory:194j8' }
      let(:file_foxml)       { File.read("#{fixture_path}/import/original_file.xml") }
      let(:original_file_id) { 'emory:194kd' }
      let(:file_foxml)       { File.read("#{fixture_path}/import/original_file.xml") }
      let(:stubbed_host)     { 'http://example.com/stubbed/' }

      before do
        WebMock.disable_net_connect!(allow_localhost: true)

        ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
        ActiveJob::Base.queue_adapter.filter = [Importer::MigrationImportJob,
                                                AttachFilesToWorkJob]

        request = '/export?context=archive&format=info:fedora/fedora-system:FOXML-1.1'

        stub_request(:get, "#{stubbed_host}#{pid}#{request}")
          .to_return(status: 200, body: foxml)
        stub_request(:get, "#{stubbed_host}#{file_id}#{request}")
          .to_return(status: 200, body: file_foxml)
        stub_request(:get, "#{stubbed_host}#{original_file_id}#{request}")
          .to_return(status: 200, body: file_foxml)
        stub_request(:get, "#{stubbed_host}#{author_id}#{request}")
          .to_return(status: 200, body: author_foxml)

        ActiveFedora::Cleaner.clean!
        WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml",
                          "#{fixture_path}/config/emory/candler_admin_sets.yml",
                          "/dev/null").setup
      end

      after { WebMock.allow_net_connect! }

      it 'imports the record' do
        expect { importer.import(record: record) }
          .to change { Etd.count }
          .by(1)
      end

      it 'retains the title' do
        importer.import(record: record)

        expect(Etd.last.title)
          .to contain_exactly 'Rules in Un-Ruled Lands: The Origins of ' \
                              "Property Rights in\nPalestinian Refugee Camp " \
                              'Sectors across Lebanon and Jordan'
      end

      it 'has a primary file' do
        importer.import(record: record)

        expect(Etd.last.representative).to be_primary
      end

      it 'has a supplementary (original) file' do
        importer.import(record: record)

        expect(Etd.last.supplemental_files_fs.first)
          .not_to be_primary
      end
    end
  end
end
