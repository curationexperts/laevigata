require 'rails_helper'

RSpec.describe FileSet do
  describe 'primary' do
    context 'with a new FileSet' do
      subject { described_class.new }

      its(:pcdm_use) { is_expected.to be_nil }
      its(:embargo_length) { is_expected.to be_nil }
      its(:primary?) { is_expected.to be false }
      its(:supplementary?) { is_expected.to be true }
    end
  end
end
