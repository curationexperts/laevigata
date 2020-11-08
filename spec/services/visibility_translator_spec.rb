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

    context 'when the etd is hidden' do
      before { obj.hidden = true }

      it 'gives the original implementation' do
        expect(translator.visibility).to eq open
      end
    end

    context 'when not under embargo' do
      let(:obj) { FactoryBot.create(:sample_data_with_nothing_embargoed) }

      it 'is open access' do
        expect(translator.visibility).to eq described_class::OPEN
      end

      it 'logs an error when state is inconsistent' do
        allow(Rails.logger).to receive(:error)

        # none of the booleans should be true if there is no embargo requested
        obj.abstract_embargoed = true
        obj.files_embargoed = false
        obj.embargo_length = 'None - open access immediately'

        expect(translator.visibility).to eq described_class::OPEN
        expect(Rails.logger).to have_received(:error).with("Inconsistent embargo values in ID: #{obj.id}")
      end
    end

    context 'when under full embargo' do
      let(:obj) { FactoryBot.create(:sample_data_with_everything_embargoed) }

      it 'is embargo (all)' do
        expect(translator.visibility).to eq described_class::ALL_EMBARGOED
      end

      it 'restricts the object when state is inconsistent' do
        allow(Rails.logger).to receive(:error)

        # one or more of the booleans should be true if there is a non-zero embargo length requested
        obj.abstract_embargoed = false
        obj.toc_embargoed = false
        obj.files_embargoed = false
        obj.embargo_length = '6 - Months'

        expect(translator.visibility).to eq described_class::RESTRICTED
        expect(Rails.logger).to have_received(:error).with("Invalid embargo values. Returning RESTRICTED for ID: #{obj.id}")
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

    context 'when the etd is hidden' do
      before { obj.hidden = true }

      it 'gives the original implementation' do
        expect(translator.visibility).to eq open
      end
    end
  end

  describe '#visibility=' do
    let(:obj) { FactoryBot.create(:etd, visibility: restricted) }

    it 'can set visibility of object to open' do
      expect { translator.visibility = open }
        .to change { obj.visibility }
        .to open
    end

    context 'when the work has no embargo' do
      it 'cannot set visibility of object to file restricted level' do
        expect { translator.visibility = described_class::FILES_EMBARGOED }
          .to raise_error ArgumentError
      end

      it 'cannot set visibility of object to toc restricted level' do
        expect { translator.visibility = described_class::TOC_EMBARGOED }
          .to raise_error ArgumentError
      end

      it 'cannot set visibility of object to all restricted level' do
        expect { translator.visibility = described_class::ALL_EMBARGOED }
          .to raise_error ArgumentError
      end
    end

    context 'when the work is under embargo' do
      let(:obj) do
        FactoryBot.create(:tomorrow_expiration,
                          files_embargoed: false,
                          toc_embargoed:   false)
      end

      it 'can set visibility of object to file restricted level' do
        expect { translator.visibility = described_class::FILES_EMBARGOED }
          .to change { obj.visibility }
          .to described_class::FILES_EMBARGOED
      end

      it 'can set visibility of object to toc restricted level' do
        expect { translator.visibility = described_class::TOC_EMBARGOED }
          .to change { obj.visibility }
          .to described_class::TOC_EMBARGOED
      end

      it 'can set visibility of object to all restricted level' do
        translator.visibility = described_class::FILES_EMBARGOED

        expect { translator.visibility = described_class::ALL_EMBARGOED }
          .to change { obj.visibility }
          .to described_class::ALL_EMBARGOED
      end
    end
  end
end
