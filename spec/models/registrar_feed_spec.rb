require 'rails_helper'

RSpec.describe RegistrarFeed, type: :model do
  let(:sample_data)   { Rails.root.join('spec', 'fixtures', 'registrar_feeds', 'registrar_sample.json') }
  let(:sample_report) { Rails.root.join('spec', 'fixtures', 'registrar_feeds', 'graduation_report.csv') }
  let(:feed) { described_class.new }

  describe "#status" do
    it 'defaults to "initialized"' do
      expect(feed.status).to eq 'initialized'
    end

    it 'only accepts valid states' do
      expect { feed.status = 'armadillo' }.to raise_exception(ArgumentError)
    end
  end

  describe '#graduation_records' do
    it 'raises an exception when missing' do
      expect { feed.save! }.to raise_exception ActiveRecord::RecordInvalid, /Graduation records must be attached/
    end

    it 'can be attached' do
      expect(feed.graduation_records).to be_a_kind_of ActiveStorage::Attached::One
    end
  end

  describe '#report' do
    it 'can be attached' do
      expect(feed.report).to be_a_kind_of ActiveStorage::Attached::One
    end
  end

  describe '#total_etds' do
    let(:feed) { described_class.new(published_etds: 100, graduated_etds: 25) }

    it 'predicts the total number of published ETDs after the graduation job runs' do
      expect(feed.total_etds).to eq 125
    end

    it 'returns nil when published_etds is nil' do
      feed.published_etds = nil
      expect(feed.total_etds).to be_nil
    end

    it 'returns nil when graduated_etds is nil' do
      feed.graduated_etds = nil
      expect(feed.total_etds).to be_nil
    end
  end
end
