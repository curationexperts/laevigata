# frozen_string_literal: true
require 'rails_helper'

describe EtdFileSetPresenter do
  let(:ability) { Ability.new(FactoryBot.build(:user)) }

  context "delegate_methods" do
    subject { presenter }
    let(:solr_fixture) { FactoryBot.build(:etd_to_solr) }
    let(:presenter) do
      described_class.new(solr_fixture, ability)
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
    let(:solr_document) { SolrDocument.new(file_set_solr_fixture) }
    let(:file_set_solr_fixture) do
      { "system_create_dtsi" => "2020-07-06T21:37:48Z", "system_modified_dtsi" => "2020-07-06T21:37:48Z", "has_model_ssim" => ["Etd"], :id => "g158bh38x", "title_tesim" => ["Legend of Blue Imp"], "title_sim" => ["Legend of Blue Imp"], "files_embargoed_bsi" => false, "files_embargoed_sim" => [false], "abstract_embargoed_bsi" => false, "abstract_embargoed_sim" => [false], "toc_embargoed_bsi" => false, "toc_embargoed_sim" => [false], "rights_statement_tesim" => ["Permission granted by the author to include this thesis or dissertation in this repository. All rights reserved by the author. Please contact the author for information regarding the reproduction and use of this thesis or dissertation."], "hidden?_bsi" => false, "thumbnail_path_ss" => "/assets/work-ff055336041c3f7d310ad69109eda4a887b16ec501f35afc0a547c4adb97ee72.png", "suppressed_bsi" => false, "member_ids_ssim" => [], "member_of_collections_ssim" => [], "member_of_collection_ids_ssim" => [], "generic_type_sim" => ["Work"], "file_set_ids_ssim" => [], "visibility_ssi" => "open", "admin_set_sim" => "", "admin_set_tesim" => "", "committee_names_sim" => [], "human_readable_type_sim" => "ETD", "human_readable_type_tesim" => "ETD", "read_access_group_ssim" => ["public"] }
      { "system_create_dtsi" => "2020-07-06T21:37:48Z", "system_modified_dtsi" => "2020-07-06T21:37:48Z", "has_model_ssim" => ["Etd"], :id => "g158bh38x", "title_tesim" => ["Legend of Blue Imp"], "title_sim" => ["Legend of Blue Imp"], "files_embargoed_bsi" => false, "files_embargoed_sim" => [false], "abstract_embargoed_bsi" => false, "abstract_embargoed_sim" => [false], "toc_embargoed_bsi" => false, "toc_embargoed_sim" => [false], "rights_statement_tesim" => ["Permission granted by the author to include this thesis or dissertation in this repository. All rights reserved by the author. Please contact the author for information regarding the reproduction and use of this thesis or dissertation."], "hidden?_bsi" => false, "thumbnail_path_ss" => "/assets/work-ff055336041c3f7d310ad69109eda4a887b16ec501f35afc0a547c4adb97ee72.png", "suppressed_bsi" => false, "member_ids_ssim" => [], "member_of_collections_ssim" => [], "member_of_collection_ids_ssim" => [], "generic_type_sim" => ["Work"], "file_set_ids_ssim" => [], "visibility_ssi" => "open", "admin_set_sim" => "", "admin_set_tesim" => "", "committee_names_sim" => [], "human_readable_type_sim" => "ETD", "human_readable_type_tesim" => "ETD", "read_access_group_ssim" => ["public"] }
    end

    it 'is the title' do
      expect(presenter.link_name).to eq "Legend of Blue Imp"
    end

    context 'when under embargo' do
      subject(:presenter) { described_class.new(solr_document, ability) }
      let(:solr_document) { SolrDocument.new(file_set_solr_fixture) }

      it 'is the title' do
        expect(presenter.link_name).to eq "Legend of Blue Imp"
      end

      context 'and viewing as an approver' do
        let(:ability)  { Ability.new(approver) }
        let(:approver) { User.where(ppid: 'candleradmin').first }

        it 'is the title' do
          expect(presenter.link_name).to eq "Legend of Blue Imp"
        end
      end
    end
  end
end
