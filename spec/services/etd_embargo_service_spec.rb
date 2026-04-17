# frozen_string_literal: true
require 'rails_helper'

describe EtdEmbargoService do
  describe '.assets_under_embargo', :clean do
    # Create one non-embargoed etd to ensure our counts are valid
    before { FactoryBot.create(:etd) }

    context 'when no works are under embargo' do
      it 'is empty' do
        expect(described_class.assets_under_embargo).to be_empty
      end

      it 'excludes non-embargoed etds' do
        expect(described_class.assets_under_embargo.count).to be < Etd.count
      end
    end

    context 'when there are embargoed etds' do
      let(:embargoed_etd) do
        FactoryBot.create(:sample_data_with_everything_embargoed)
      end

      before { embargoed_etd } # create the etd with embargo

      it 'has only the emborgoed etds' do
        expect(described_class.assets_under_embargo.map(&:id))
          .to contain_exactly embargoed_etd.id
      end

      context 'and embargoed FileSets' do
        let(:embargoed_etd) { FactoryBot.create(:sample_data_with_everything_embargoed, ordered_members: [primary_file], representative: primary_file) }
        let(:primary_file) { build(:primary_file_set) }

        before do
          # Ensure file_sets are also embargoed
          embargoed_etd.members.each do |file_set|
            file_set.embargo = embargoed_etd.embargo
            file_set.save!
          end
        end

        it 'includes only the embargoed etds (not the FileSets)' do
          expect(described_class.assets_under_embargo.map(&:id))
            .to contain_exactly embargoed_etd.id
        end
      end
    end
  end
end
