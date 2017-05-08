require 'rails_helper'

RSpec.describe FileSet do
  describe 'primary' do
    subject { described_class.new }

    context 'with a new FileSet' do
      its(:primary?) { is_expected.not_to be_truthy }
      its(:supplementary?) { is_expected.to be_truthy }
    end

    context 'with a FileSet marked primary' do
      # TODO
      its(:primary?) { is_expected.to be_truthy }
      its(:supplementary?) { is_expected.not_to be_truthy }
    end
  end
end
