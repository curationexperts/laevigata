require 'rails_helper'

describe FileSetVisibilityTranslator do
  subject(:translator) { described_class.new(obj: obj) }
  let(:obj) { FactoryBot.build(:file_set) }

  let(:open)       { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
  let(:restricted) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }

  describe '.visibility' do
    it 'passes through to object visibility' do
      expect(described_class.visibility(obj: obj)).to eq obj.visibility
    end
  end

  describe '#visibility' do
    it 'passes through to object visibility' do
      expect(translator.visibility).to eq obj.visibility
    end
  end

  describe '#visibility=' do
    it 'can set to open' do
      expect { translator.visibility = open }
        .to change { obj.visibility }
        .to open
    end

    context 'when open' do
      let(:obj) { FactoryBot.build(:file_set, visibility: open) }

      it 'can set to restricted' do
        expect { translator.visibility = restricted }
          .to change { obj.visibility }
          .to restricted
      end

      it 'sets visibility to restricted for file restricted' do
        expect { translator.visibility = VisibilityTranslator::FILES_EMBARGOED }
          .to change { obj.visibility }
          .to restricted
      end

      it 'sets visibility to restricted for toc restricted' do
        expect { translator.visibility = VisibilityTranslator::TOC_EMBARGOED }
          .to change { obj.visibility }
          .to restricted
      end

      it 'sets visibility to restricted for all restricted' do
        expect { translator.visibility = VisibilityTranslator::ALL_EMBARGOED }
          .to change { obj.visibility }
          .to restricted
      end
    end
  end
end
