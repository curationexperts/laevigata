# frozen_string_literal: true
require 'rails_helper'

describe EtdPresenter do
  context "table of contents" do
    context "without a table of contents" do
      let(:etd) { FactoryGirl.build(:etd) }
      let(:ability) { Ability.new(FactoryGirl.build(:user)) }
      let(:presenter) do
        described_class.new(SolrDocument.new(etd.to_solr), ability)
      end
      it "tells the user that no toc is available" do
        expect(etd.table_of_contents).to eq []
        expect(presenter.toc_with_embargo_check).to eq "No table of contents is available."
      end
    end
    context "with a table of contents" do
      let(:etd) { FactoryGirl.build(:etd_with_toc) }
      context "with a public user" do
        let(:ability) { Ability.new(FactoryGirl.build(:user)) }
        let(:presenter) do
          described_class.new(SolrDocument.new(etd.to_solr), ability)
        end
        it "returns the toc if the toc is not under embargo" do
          expect(etd.toc_embargoed).to eq nil
          expect(presenter.toc_with_embargo_check).to eq etd.table_of_contents.first
        end
        context "with a toc embargo" do
          it "provides a toc unavailable message if the toc is under embargo" do
            etd.embargo_id = FactoryGirl.create(:embargo, embargo_release_date: (DateTime.current + 14).to_s).id
            etd.toc_embargoed = true
            expect(presenter.toc_with_embargo_check).to eq "This table of contents is under embargo until #{presenter.formatted_embargo_release_date}"
          end
        end
      end
      context "with an admin user" do
        let(:ability) { Ability.new(FactoryGirl.build(:admin)) }
        let(:presenter) do
          described_class.new(SolrDocument.new(etd.to_solr), ability)
        end
        it "returns the toc if the toc is not under embargo" do
          expect(etd.toc_embargoed).to eq nil
          expect(presenter.toc_with_embargo_check).to eq etd.table_of_contents.first
        end
        context "with a toc embargo" do
          it "displays the toc even if it is under embargo" do
            etd.embargo_id = FactoryGirl.create(:embargo, embargo_release_date: (DateTime.current + 14).to_s).id
            etd.toc_embargoed = true
            expect(presenter.toc_with_embargo_check).to eq "[Embargoed until #{presenter.formatted_embargo_release_date}] #{presenter.table_of_contents.first}"
          end
        end
      end
    end
  end

  context "abstract" do
    context "without an abstract" do
      let(:etd) { FactoryGirl.build(:etd) }
      let(:ability) { Ability.new(FactoryGirl.build(:user)) }
      let(:presenter) do
        described_class.new(SolrDocument.new(etd.to_solr), ability)
      end
      it "tells the user that no abstract is available" do
        expect(etd.abstract).to eq []
        expect(presenter.abstract_with_embargo_check).to eq "No abstract is available."
      end
    end
    context "with an abstract" do
      let(:etd) { FactoryGirl.build(:etd_with_abstract) }
      context "with a public user" do
        let(:ability) { Ability.new(FactoryGirl.build(:user)) }
        let(:presenter) do
          described_class.new(SolrDocument.new(etd.to_solr), ability)
        end
        it "returns the abstract if it is not under embargo" do
          expect(etd.abstract_embargoed).to eq nil
          expect(presenter.abstract_with_embargo_check).to eq etd.abstract.first
        end
        context "with an abstract embargo" do
          it "provides an abstract unavailable message if the abstract is under embargo" do
            etd.embargo_id = FactoryGirl.create(:embargo, embargo_release_date: (DateTime.current + 14).to_s).id
            etd.abstract_embargoed = true
            expect(presenter.abstract_with_embargo_check).to eq "This abstract is under embargo until #{presenter.formatted_embargo_release_date}"
          end
        end
      end
      context "with an admin user" do
        let(:ability) { Ability.new(FactoryGirl.build(:admin)) }
        let(:presenter) do
          described_class.new(SolrDocument.new(etd.to_solr), ability)
        end
        it "returns the abstract if it is not under embargo" do
          expect(etd.abstract_embargoed).to eq nil
          expect(presenter.abstract_with_embargo_check).to eq etd.abstract.first
        end
        context "with an abstract embargo" do
          it "displays the abstract even if it is under embargo" do
            etd.embargo_id = FactoryGirl.create(:embargo, embargo_release_date: (DateTime.current + 14).to_s).id
            etd.abstract_embargoed = true
            expect(presenter.abstract_with_embargo_check).to eq "[Embargoed until #{presenter.formatted_embargo_release_date}] #{presenter.abstract.first}"
          end
        end
      end
    end
  end

  # TODO: Ensure this always exists in the future.
  # Make a new fixture object that always has a future embargo date.
  context "embargoes" do
    let(:etd) { FactoryGirl.build(:ateer_etd) }
    let(:ability) { Ability.new(FactoryGirl.build(:user)) }
    let(:presenter) do
      described_class.new(SolrDocument.new(etd.to_solr), ability)
    end
    it "gets the embargo_release_date in a printable form" do
      expect(presenter.formatted_embargo_release_date).to eq "21 August 2017"
    end
  end

  context "delegate_methods" do
    subject { presenter }

    let(:title) { ['China and its Minority Population'] }
    let(:creator) { ['Eun, Dongwon'] }
    let(:keyword) { ['China', 'Minority Population'] }
    let(:degree) { ['MS'] }
    let(:department) { ['Religion'] }
    let(:school) { ['Laney Graduate School'] }
    let(:subfield) { ['Ethics and Society'] }
    let(:partnering_agency) { ["Does not apply (no collaborating organization)"] }
    let(:submitting_type) { ["Honors Thesis"] }
    let(:research_field) { ['Toxicology'] }
    let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    let :etd do
      Etd.new(title: title, creator: creator, keyword: keyword, degree: degree, department: department,
              school: school, subfield: subfield, partnering_agency: partnering_agency, submitting_type: submitting_type,
              research_field: research_field, visibility: visibility)
    end

    let(:ability) { Ability.new(user) }

    let(:presenter) do
      described_class.new(SolrDocument.new(etd.to_solr), nil)
    end

    # If the fields require no addition logic for display, you can simply delegate
    # them to the solr document
    it { is_expected.to delegate_method(:degree).to(:solr_document) }
    it { is_expected.to delegate_method(:department).to(:solr_document) }
    it { is_expected.to delegate_method(:school).to(:solr_document) }
    it { is_expected.to delegate_method(:subfield).to(:solr_document) }
    it { is_expected.to delegate_method(:partnering_agency).to(:solr_document) }
    it { is_expected.to delegate_method(:submitting_type).to(:solr_document) }
    it { is_expected.to delegate_method(:research_field).to(:solr_document) }
  end
end
