# frozen_string_literal: true
require 'rails_helper'

RSpec.describe EtdFormHelper do
  describe '#summarize_committee_member' do
    subject(:summary) {
      summarize_committee_member(label, attrs)
    }

    let(:label) { 'My Committee Member' }
    let(:attrs) {
      { 'name' => ['Professor Martin'],
        'affiliation' => ['Emory University'] }
    }

    it 'returns the displayable summary' do
      expect(summary).to match(/\A.*My Committee Member.*Professor Martin \(Emory University\).*\Z/)
    end
  end
end
