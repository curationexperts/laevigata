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
end
