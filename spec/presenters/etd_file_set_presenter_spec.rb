# frozen_string_literal: true
require 'rails_helper'

describe EtdFileSetPresenter do
  let(:ability) { Ability.new(FactoryBot.build(:user)) }
  let(:etd)     { FactoryBot.build(:etd) }

  context "delegate_methods" do
    subject { presenter }

    let(:presenter) do
      described_class.new(SolrDocument.new(etd.to_solr), ability)
    end

    # If the fields require no addition logic for display, you can simply delegate
    # them to the solr document
    it { is_expected.to delegate_method(:pcdm_use).to(:solr_document) }

    it "returns an array with an empty string from permission_badge" do
      expect(presenter.permission_badge).to eq ""
    end
  end

  describe '#link_name' do
    subject(:presenter) { described_class.new(solr_document, ability) }
    let(:solr_document) { SolrDocument.new(etd.primary_file_fs.first.to_solr) }

    let(:etd) do
      etd = FactoryBot.create(:sample_data_with_everything_embargoed,
                              school: ["Candler School of Theology"])
      primary_pdf_file = "#{::Rails.root}/spec/fixtures/joey/joey_thesis.pdf"
      etd_factory      = EtdFactory.new
      etd_factory.etd  = etd

      etd_factory.primary_pdf_file = primary_pdf_file
      etd_factory.attach_primary_pdf_file

      etd.save
      etd
    end

    it 'is the title' do
      expect(presenter.link_name).to eq etd.title.first
    end

    context 'when under embargo' do
      subject(:presenter) { described_class.new(solr_document, ability) }
      let(:solr_document) { SolrDocument.new(etd.primary_file_fs.first.to_solr) }

      it 'is the title' do
        expect(presenter.link_name).to eq  etd.title.first
      end

      context 'and viewing as an approver' do
        let(:ability)  { Ability.new(approver) }
        let(:approver) { User.where(ppid: 'candleradmin').first }

        it 'is the title' do
          expect(presenter.link_name).to eq etd.title.first
        end
      end
    end
  end
end
