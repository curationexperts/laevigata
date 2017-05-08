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
end
