require 'rails_helper'

RSpec.describe FileSet do
  describe 'primary' do
    subject { described_class.new }

    context 'with a new FileSet' do
      its(:primary) { is_expected.to be_nil }
      its(:primary?) { is_expected.to be false }
      its(:supplementary?) { is_expected.to be true }
    end

    context 'with a FileSet marked primary' do
      # TODO
      its(:primary?) { is_expected.to be true }
      its(:supplementary?) { is_expected.to be false }
    end
  end

  describe 'supplementary' do
    context 'with a new FileSet' do
      subject { described_class.new }

      its(:primary) { is_expected.to be_nil }
      its(:primary?) { is_expected.to be false }
      its(:supplementary?) { is_expected.to be true }
    end

    context 'when created, but not as supplementary' do
      subject { described_class.create(supplementary: 'http://pcdm.org/use#primary') }

      its(:primaty) { is_expected.to eq 'http://pcdm.org/use#primary' }
      its(:primary?) { is_expected.to be true }
      its(:supplementary?) { is_expected.to be false }
    end

    context 'when created as supplementary' do
      subject { described_class.create(supplementary: 'http://pcdm.org/use#supplementary') }

      its(:supplementary) { is_expected.to eq 'http://pcdm.org/use#supplementary' }
      its(:supplementary?) { is_expected.to be true }
      its(:primary?) { is_expected.to be false }
    end
  end
end
