# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ::SolrDocument, type: :model do
  describe '#description' do
    subject(:description) { solr_doc.description }

    let(:solr_doc) { described_class.new(coll.to_solr) }

    context 'A collection with a description' do
      let(:desc) { 'A Description of My Collection' }
      let(:coll) { Collection.new(title: ['A'], description: [desc]) }

      it { is_expected.to eq [desc] }
    end

    context 'A collection without a description' do
      let(:coll) { Collection.new(title: ['A']) }

      # Because some views assume array. Story #1204.
      it 'returns an empty array' do
        expect(description).to eq []
      end
    end
  end
end
