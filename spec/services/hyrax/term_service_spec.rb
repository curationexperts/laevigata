# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TermService do
  let(:term_service) { described_class.new(etd_terms: terms) }
  let(:terms) { Hyrax::EtdForm.terms }
  describe 'getting the filtered terms' do
    it 'is initialized with all the etd terms' do
      expect(term_service.terms).to include(:identifier)
    end
    it 'returns the filtered terms' do
      expect(term_service.filtered_terms).not_to include(term_service.rejected_terms)
    end
  end
end
