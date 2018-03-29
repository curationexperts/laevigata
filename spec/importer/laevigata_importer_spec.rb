require 'rails_helper'
require 'darlingtonia/spec'

RSpec.describe Importer::LaevigataImporter do
  subject(:parser) { described_class.new(file: file) }
  let(:file)       { Tempfile.new(['fake', '.txt']) }

  it_behaves_like 'a Darlingtonia::Parser' do
    let(:record_count) { 0 }
  end

  context 'with pids to import' do
    let(:pids) { "1\n2\n3\n4\n5\n" }

    before do
      file.write(pids)
      file.rewind
    end

    it_behaves_like 'a Darlingtonia::Parser' do
      let(:record_count) { 5 }
    end

    describe '#source_host' do
      context 'when set' do
        let(:source_host) { 'http://example.com/fedora/objects/' }

        before { parser.source_host = source_host }

        it' passes to mapper' do
          expect(parser.records.first.mapper)
            .to have_attributes(source_host: source_host)
        end
      end
    end
  end
end
