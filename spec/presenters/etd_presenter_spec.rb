# frozen_string_literal: true
require 'rails_helper'

describe EtdPresenter do
  context "table of contents" do
    context "without a table of contents" do
      let(:etd) { FactoryBot.build(:etd) }
      let(:ability) { Ability.new(FactoryBot.build(:user)) }
      let(:presenter) do
        described_class.new(SolrDocument.new(etd.to_solr), ability)
      end
      it "tells the user that no toc is available" do
        expect(etd.table_of_contents).to eq []
        expect(presenter.toc_with_embargo_check).to eq "No table of contents is available."
      end
    end
    context "with a table of contents" do
      let(:etd) { FactoryBot.build(:etd_with_toc) }
      context "with a public user" do
        let(:ability) { Ability.new(FactoryBot.build(:user)) }
        let(:presenter) do
          described_class.new(SolrDocument.new(etd.to_solr), ability)
        end
        it "returns the toc if the toc is not under embargo" do
          allow(presenter).to receive(:current_ability_is_approver?).and_return(false)
          expect(etd.toc_embargoed).to eq nil
          expect(presenter.toc_with_embargo_check).to eq etd.table_of_contents.first
        end

        context "with a toc embargo" do
          let(:etd) do
            FactoryBot.build(:etd_with_toc, embargo_id: embargo.id, toc_embargoed: true)
          end

          let(:embargo) do
            FactoryBot.create(:embargo, embargo_release_date: (DateTime.current + 14).to_s)
          end

          context "with a public user" do
            it "provides a toc unavailable message if the toc is under embargo" do
              presenter = described_class.new(SolrDocument.new(etd.to_solr), ability)
              allow(presenter).to receive(:current_ability_is_approver?).and_return(false)
              expect(presenter.toc_with_embargo_check).to eq "This table of contents is under embargo until #{presenter.formatted_embargo_release_date}"
            end
          end

          describe '#toc_for_admin' do
            it 'gives the table of contents' do
              expect(presenter.toc_for_admin).to include(etd.table_of_contents.first)
            end

            it 'lists the embargo length' do
              expect(presenter.toc_for_admin)
                .to include(presenter.formatted_embargo_release_date)
            end

            context 'when the degree is awarded' do
              let(:etd) do
                FactoryBot.build(:etd_with_toc,
                                 embargo_id:     embargo.id,
                                 toc_embargoed:  true,
                                 degree_awarded: true)
              end

              it 'lists the embargo' do
                expect(presenter.toc_for_admin).to include(etd.table_of_contents.first)
              end

              it 'lists the embargo release date' do
                expect(presenter.toc_for_admin)
                  .to include(presenter.formatted_embargo_release_date)
              end
            end
          end
        end
        context "with an admin user" do
          let(:ability) { Ability.new(FactoryBot.build(:admin)) }
          let(:presenter) do
            described_class.new(SolrDocument.new(etd.to_solr), ability)
          end
          it "returns the toc if it is not under embargo" do
            expect(etd.toc_embargoed).to eq nil
            expect(presenter.toc_with_embargo_check).to eq etd.table_of_contents.first
          end
          context "pre-graduation" do
            it "displays the table_of_contents with embargo_length" do
              etd.embargo_length = "6 months"
              etd.degree_awarded = nil
              etd.embargo_id = FactoryBot.create(:embargo, embargo_release_date: (DateTime.current + 14).to_s).id
              etd.toc_embargoed = true
              presenter = described_class.new(SolrDocument.new(etd.to_solr), ability)
              expect(presenter.toc_with_embargo_check).to eq "[Table of contents embargoed until #{etd.embargo_length} post-graduation] #{presenter.table_of_contents.first}"
            end
          end
          context "post-graduation" do
            it "displays the table_of_contents with the embargo release date" do
              etd.embargo_length = "6 months"
              etd.degree_awarded = Date.parse("17-05-17").strftime("%d %B %Y")
              etd.embargo_id = FactoryBot.create(:embargo, embargo_release_date: (DateTime.current + 14).to_s).id
              etd.toc_embargoed = true
              presenter = described_class.new(SolrDocument.new(etd.to_solr), ability)
              expect(presenter.toc_with_embargo_check).to eq "[Table of contents embargoed until #{presenter.formatted_embargo_release_date}] #{presenter.table_of_contents.first}"
            end
          end
        end
      end
    end
  end

  context "abstract" do
    context "without an abstract" do
      let(:etd) { FactoryBot.build(:etd) }
      let(:ability) { Ability.new(FactoryBot.build(:user)) }
      let(:presenter) do
        described_class.new(SolrDocument.new(etd.to_solr), ability)
      end
      it "tells the user that no abstract is available" do
        expect(etd.abstract).to eq []
        expect(presenter.abstract_with_embargo_check).to eq "No abstract is available."
      end
    end
    context "with an abstract" do
      let(:etd) { FactoryBot.build(:etd_with_abstract) }
      context "with a public user" do
        let(:ability) { Ability.new(FactoryBot.build(:user)) }
        let(:presenter) do
          described_class.new(SolrDocument.new(etd.to_solr), ability)
        end
        before { allow(presenter).to receive(:current_ability_is_approver?).and_return(false) }
        it "returns the abstract if it is not under embargo" do
          expect(etd.abstract_embargoed).to eq nil
          expect(presenter.abstract_with_embargo_check).to eq etd.abstract.first
        end
        context "with an abstract embargo pre-graduation" do
          it "provides an abstract unavailable message with embargo_length" do
            etd.embargo_id = FactoryBot.create(:embargo, embargo_release_date: (DateTime.current + 14).to_s).id
            etd.abstract_embargoed = true
            etd.save
            presenter = described_class.new(SolrDocument.new(etd.to_solr), ability)
            allow(presenter).to receive(:current_ability_is_approver?).and_return(false)
            expect(presenter.abstract_with_embargo_check).to eq "This abstract is under embargo until #{presenter.formatted_embargo_release_date}"
          end
        end
        context "with an abstract embargo post-graduation" do
          it "provides an abstract unavailable message with embargo_release_date" do
            etd.embargo_id = FactoryBot.create(:embargo, embargo_release_date: (DateTime.current + 14).to_s).id
            etd.abstract_embargoed = true
            etd.save
            presenter = described_class.new(SolrDocument.new(etd.to_solr), ability)
            allow(presenter).to receive(:current_ability_is_approver?).and_return(false)
            expect(presenter.abstract_with_embargo_check).to eq "This abstract is under embargo until #{presenter.formatted_embargo_release_date}"
          end
        end
      end
      context "with an admin user" do
        let(:ability) { Ability.new(FactoryBot.build(:admin)) }
        let(:presenter) do
          described_class.new(SolrDocument.new(etd.to_solr), ability)
        end
        it "returns the abstract if it is not under embargo" do
          expect(etd.abstract_embargoed).to eq nil
          expect(presenter.abstract_with_embargo_check).to eq etd.abstract.first
        end
        context "with an abstract embargo pre-graduation" do
          it "displays the abstract with embargo_length" do
            etd.embargo_length = "6 months"
            etd.degree_awarded = nil
            etd.embargo_id = FactoryBot.create(:embargo, embargo_release_date: (DateTime.current + 14).to_s).id
            etd.abstract_embargoed = true
            presenter = described_class.new(SolrDocument.new(etd.to_solr), ability)
            expect(presenter.abstract_with_embargo_check).to eq "[Abstract embargoed until #{etd.embargo_length} post-graduation] #{presenter.abstract.first}"
          end
        end
        context "with an abstract embargo post-graduation" do
          it "displays the abstract with the embargo release date" do
            etd.embargo_length = "6 months"
            etd.degree_awarded = Date.parse("17-05-17").strftime("%d %B %Y")
            etd.embargo_id = FactoryBot.create(:embargo, embargo_release_date: (DateTime.current + 14).to_s).id
            etd.abstract_embargoed = true
            presenter = described_class.new(SolrDocument.new(etd.to_solr), ability)
            expect(presenter.abstract_with_embargo_check).to eq "[Abstract embargoed until #{presenter.formatted_embargo_release_date}] #{presenter.abstract.first}"
          end
        end
      end
    end
  end

  context "embargoes" do
    let(:etd) { FactoryBot.build(:sample_data_with_everything_embargoed) }
    let(:ability) { Ability.new(FactoryBot.build(:user)) }
    let(:presenter) do
      described_class.new(SolrDocument.new(etd.to_solr), ability)
    end
    it "gets the embargo_release_date in a printable form" do
      expect(presenter.formatted_embargo_release_date).to eq((Time.zone.today + 14.days).strftime("%d %B %Y"))
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
              research_field: research_field, visibility: visibility, copyright_question_one: true, copyright_question_two: false, copyright_question_three: true)
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
    it { is_expected.to delegate_method(:copyright_question_one).to(:solr_document) }
    it { is_expected.to delegate_method(:copyright_question_two).to(:solr_document) }
    it { is_expected.to delegate_method(:copyright_question_three).to(:solr_document) }
  end
end
