# frozen_string_literal: true
require 'rails_helper'

describe EtdEmbargoService do
  describe '.assets_under_embargo' do
    before { FactoryBot.create(:etd) }

    context 'when no works are under embargo' do
      it 'is empty' do
        expect(described_class.assets_under_embargo).to be_empty
      end
    end

    context 'when there are embargoed etds', :clean do
      let(:embargoed_etd) do
        FactoryBot.create(:sample_data_with_everything_embargoed)
      end

      before { embargoed_etd } # create the etd with embargo

      it 'has only the emborgoed etds' do
        expect(described_class.assets_under_embargo.map(&:id))
          .to contain_exactly embargoed_etd.id
      end

      context 'and embargoed FileSets' do
        before do
          primary_pdf_file = "#{::Rails.root}/spec/fixtures/joey/joey_thesis.pdf"
          etd_factory      = EtdFactory.new
          etd_factory.etd  = embargoed_etd

          etd_factory.primary_pdf_file = primary_pdf_file
          etd_factory.attach_primary_pdf_file

          embargoed_etd.save

          # fail in setup if the embargo didn't apply; if there's no FileSet
          # embargo, the tests in this context are not useful.
          expect(embargoed_etd.representative.embargo).to be_present
        end

        it 'has only the emborgoed etds (not the FileSets)' do
          expect(described_class.assets_under_embargo.map(&:id))
            .to contain_exactly embargoed_etd.id
        end
      end
    end
  end
end
