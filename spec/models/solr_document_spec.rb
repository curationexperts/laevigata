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

  describe '#date_modified' do
    subject(:solr_doc) { described_class.new(etd.to_solr) }
    let(:etd)          { FactoryBot.build(:etd, hidden: true) }

    it 'returns the date uploaded as EST' do
      etd.date_modified = '01/01/2019 3 AM'.to_date.in_time_zone
      expect(solr_doc.date_modified).to eq('2018-12-31 19:00:00 -0500')
    end
  end

  describe '#date_uploaded' do
    subject(:solr_doc) { described_class.new(etd.to_solr) }
    let(:etd)          { FactoryBot.build(:etd, hidden: true) }

    it 'returns the date uploaded as EST' do
      etd.date_uploaded = '01/01/2019 3 AM'.to_date.in_time_zone
      expect(solr_doc.date_uploaded).to eq('2018-12-31 19:00:00 -0500')
    end
  end

  describe '#degree_awarded' do
    subject(:solr_doc) { described_class.new(etd.to_solr) }
    let(:etd)          { FactoryBot.build(:etd) }

    it 'returns the degree_awarded in UTC' do
      etd.degree_awarded = 'May 15, 1848'
      expect(solr_doc.degree_awarded).to match('1848-05-15T')
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

    describe '#under_embargo?' do
      context 'with no embargo' do
        let(:etd) { FactoryBot.build(:etd, embargo_release_date: nil) }
        it 'returns false' do
          expect(solr_doc.under_embargo?).to be false
        end
      end
      context 'with a release date in the past' do
        let(:etd) { FactoryBot.build(:etd, embargo_release_date: 1.month.ago) }
        it 'returns false' do
          expect(solr_doc.under_embargo?).to be false
        end
      end
      context 'with a future release date' do
        let(:etd) { FactoryBot.build(:etd, embargo_release_date: 1.month.from_now) }
        it 'returns true' do
          expect(solr_doc.under_embargo?).to be true
        end
      end
    end

    context 'when under embargo' do
      subject(:etd) do
        FactoryBot.build(:tomorrow_expiration,
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
