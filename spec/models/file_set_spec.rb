require 'rails_helper'

RSpec.describe FileSet do
  subject(:file_set) { described_class.new }

  describe '#admin_set' do
    it 'has no admin_set of its own' do
      expect(file_set.admin_set).to be_nil
    end

    context 'when it belongs to a work' do
      let(:etd)       { FactoryBot.build(:etd, admin_set: admin_set) }
      let(:admin_set) { FactoryBot.create(:admin_set) }

      before do
        etd.ordered_members << file_set
        etd.save
      end

      it 'gives the admin_set for the parent work' do
        expect(file_set.admin_set).to eq admin_set
      end
    end
  end

  context 'with a new FileSet' do
    its(:pcdm_use) { is_expected.to be_nil }
    its(:embargo_length) { is_expected.to be_nil }
    its(:premis?) { is_expected.to be false }
    its(:primary?) { is_expected.to be false }
    its(:supplementary?) { is_expected.to be true }
    its(:title) { is_expected.to eq [] }
    its(:description) { is_expected.to eq [] }
    its(:file_type) { is_expected.to be_nil }
  end

  context 'when original' do
    subject(:file_set) { described_class.new(pcdm_use: described_class::ORIGINAL) }

    its(:pcdm_use) { is_expected.to eq described_class::ORIGINAL }

    it { is_expected.not_to be_premis }
    it { is_expected.not_to be_primary }
    it { is_expected.not_to be_supplementary }
    it { is_expected.to be_original }
  end

  context 'when premis' do
    subject(:file_set) { described_class.new(pcdm_use: described_class::PREMIS) }

    its(:pcdm_use) { is_expected.to eq described_class::PREMIS }

    it { is_expected.to be_premis }
    it { is_expected.not_to be_primary }
    it { is_expected.not_to be_supplementary }
    it { is_expected.not_to be_original }
  end

  context 'when primary' do
    subject(:file_set) { described_class.new(pcdm_use: described_class::PRIMARY) }

    its(:pcdm_use) { is_expected.to eq described_class::PRIMARY }

    it { is_expected.not_to be_premis }
    it { is_expected.to be_primary }
    it { is_expected.not_to be_supplementary }
    it { is_expected.not_to be_original }
  end

  context 'when supplementary' do
    subject(:file_set) { described_class.new(pcdm_use: described_class::SUPPLEMENTARY) }

    its(:pcdm_use) { is_expected.to eq described_class::SUPPLEMENTARY }

    it { is_expected.not_to be_premis }
    it { is_expected.not_to be_primary }
    it { is_expected.to be_supplementary }
    it { is_expected.not_to be_original }
  end
end
