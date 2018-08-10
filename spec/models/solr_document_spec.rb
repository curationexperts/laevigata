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

  describe '#hidden?' do
    subject(:solr_doc) { described_class.new(etd.to_solr) }
    let(:etd)          { FactoryBot.build(:etd, hidden: true) }

    it 'is hidden' do
      expect(solr_doc).to be_hidden
    end
  end

  describe '#visibility' do
    subject(:solr_doc) { described_class.new(etd.to_solr) }
    let(:etd)          { FactoryBot.build(:etd) }

    it 'is public' do
      expect(solr_doc.visibility)
        .to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    end

    context 'when private' do
      let(:etd)     { FactoryBot.build(:etd, visibility: private) }
      let(:private) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }

      it 'is private' do
        expect(solr_doc.visibility).to eq private
      end
    end

    context 'when under embargo' do
      subject(:etd) do
        FactoryBot.create(:tomorrow_expiration,
                          files_embargoed: false,
                          toc_embargoed:   false)
      end

      it 'is restricted to all' do
        expect(solr_doc.visibility).to eq VisibilityTranslator::ALL_EMBARGOED
      end

      it 'reflects file level embargo' do
        etd.visibility = VisibilityTranslator::FILES_EMBARGOED
        expect(solr_doc.visibility).to eq VisibilityTranslator::FILES_EMBARGOED
      end

      it 'reflects toc level embargo' do
        etd.visibility = VisibilityTranslator::TOC_EMBARGOED
        expect(solr_doc.visibility).to eq VisibilityTranslator::TOC_EMBARGOED
      end
    end
  end
end
