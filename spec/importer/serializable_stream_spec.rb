require 'rails_helper'

RSpec.describe Importer::SerializableStream do
  subject(:stream)  { described_class.new(base_stream) }
  let(:base_stream) { [] }

  describe '#<<' do
    let(:message) { 'a message' }

    it 'writes to the underlying stream' do
      expect { stream << message }
        .to change { base_stream }
        .to contain_exactly "[MIGRATION]: #{message}\n"
    end
  end

  describe '.find' do
    it 'returns a stream wrapping the ActiveJob::Logger' do
      expect(described_class.find('logger')).to be_a(described_class)
    end

    it 'raises an error for unexpected ids' do
      expect { described_class.find('moomin') }.to raise_error(/moomin/)
    end
  end
end
