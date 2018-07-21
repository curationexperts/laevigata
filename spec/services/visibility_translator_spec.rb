require 'rails_helper'

describe VisibilityTranslator do
  subject(:translator) { described_class.new(obj: obj) }

  let(:obj) { FactoryBot.create(:etd, visibility: open) }

  let(:embargo)    { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO }
  let(:open)       { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
  let(:restricted) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }

  describe '.visibility' do
    it 'passes through to an instance' do
      expect(described_class.visibility(obj: obj))
        .to eq translator.visibility
    end
  end

  describe '#visibility' do
    it 'is open' do
      expect(translator.visibility).to eq open
    end

    context 'when under full embargo' do
      let(:obj) { FactoryBot.create(:sample_data_with_everything_embargoed) }

      it 'is embargo (all)' do
        expect(translator.visibility).to eq described_class::ALL_EMBARGOED
      end
    end

    context 'when under file-only embargo' do
      let(:obj) { FactoryBot.create(:sample_data_with_only_files_embargoed) }

      it 'is embargo (file)' do
        expect(translator.visibility).to eq described_class::FILES_EMBARGOED
      end
    end

    context 'when under toc embargo' do
      let(:obj) do
        FactoryBot.create(:sample_data_with_only_files_embargoed, toc_embargoed: true)
      end

      it 'is embargo (toc + file)' do
        expect(translator.visibility).to eq described_class::TOC_EMBARGOED
      end
    end

    context 'when restricted' do
      let(:obj) { FactoryBot.create(:etd, visibility: restricted) }

      it 'is restricted' do
        expect(translator.visibility).to eq restricted
      end
    end
  end
end
