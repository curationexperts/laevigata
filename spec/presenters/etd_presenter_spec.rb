# frozen_string_literal: true
require 'rails_helper'

describe EtdPresenter do
  let(:etd) { FactoryBot.build(:etd) }
  let(:ability) { Ability.new(FactoryBot.build(:user)) }
  let(:presenter) { described_class.new(SolrDocument.new(etd.to_solr), ability) }

  context "pretty printing" do
    context "#degree_awarded" do
      it 'displays in a friendly format' do
        etd.degree_awarded = Time.new(1960, 8, 23, 13, 30, 0, 0.00).utc
        expect(presenter.degree_awarded).to eq "23 August 1960"
      end

      it 'handles nil' do
        etd.degree_awarded = nil
        expect(presenter.degree_awarded).to eq "graduation pending"
      end
    end

    context "#submitting_type" do
      it 'always returns the first value' do
        etd.submitting_type = ["Fee", "Fee"] # duplicate values because RDF won't guarantee order
        expect(presenter.submitting_type).to eq 'Fee'
      end

      it 'returns a placeholder value when empty' do
        etd.submitting_type = nil
        expect(presenter.submitting_type).to eq 'ETD'
      end
    end
  end

  context "table of contents" do
    context "without a table of contents" do
      it "tells the user that no toc is available" do
        expect(etd.table_of_contents).to eq []
        expect(presenter.toc_with_embargo_check).to eq "No table of contents is available."
      end
    end
    context "with a table of contents" do
      let(:etd) { FactoryBot.build(:etd_with_toc) }
      context "with a public user" do
        it "returns the toc if the toc is not under embargo" do
          allow(presenter).to receive(:current_ability_is_approver?).and_return(false)
          expect(etd.toc_embargoed).to be_falsey
          expect(presenter.toc_with_embargo_check).to eq etd.table_of_contents.first
        end

        context "with a toc embargo" do
          let(:etd) { FactoryBot.build(:etd_with_toc, embargo_id: embargo.id, toc_embargoed: true) }
          let(:embargo) { FactoryBot.create(:embargo, embargo_release_date: (DateTime.current + 14).to_s) }

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
              let(:etd) {
                FactoryBot.build(:etd_with_toc,
                               embargo_id: embargo.id,
                               toc_embargoed: true,
                               degree_awarded: '2017-05-31')
              }

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
          it "returns the toc if it is not under embargo" do
            expect(etd.toc_embargoed).to be_falsey
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
      it "tells the user that no abstract is available" do
        expect(etd.abstract).to eq []
        expect(presenter.abstract_with_embargo_check).to eq "No abstract is available."
      end
    end
    context "with an abstract" do
      let(:etd) { FactoryBot.build(:etd_with_abstract) }
      context "with a public user" do
        before { allow(presenter).to receive(:current_ability_is_approver?).and_return(false) }
        it "returns the abstract if it is not under embargo" do
          expect(etd.abstract_embargoed).to be_falsey
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
        it "returns the abstract if it is not under embargo" do
          expect(etd.abstract_embargoed).to be_falsey
          expect(presenter.abstract_with_embargo_check).to eq etd.abstract.first
        end

        context 'with an abstract embargo' do
          let(:degree_awarded) { nil }
          let(:embargo_length) { '6 months' }

          before do
            etd.embargo_length     = embargo_length
            etd.abstract_embargoed = true
            etd.degree_awarded     = degree_awarded

            etd.embargo_id =
              FactoryBot.create(:embargo, embargo_release_date: (DateTime.current + 14).to_s).id
          end

          context "pre-graduation" do
            it "displays the abstract with embargo_length" do
              expect(presenter.abstract_with_embargo_check)
                .to eq "[Abstract embargoed until #{etd.embargo_length} post-graduation] #{presenter.abstract.first}"
            end
          end

          context "post-graduation" do
            let(:degree_awarded) { Date.parse("17-05-17").strftime("%d %B %Y") }

            it "displays the abstract with the embargo release date" do
              expect(presenter.abstract_with_embargo_check)
                .to eq "[Abstract embargoed until #{presenter.formatted_embargo_release_date}] #{presenter.abstract.first}"
            end
          end

          context "but no #embargo_length" do
            let(:embargo_length) { nil }

            it "displays the abstract with embargo_length" do
              expect(presenter.abstract_with_embargo_check)
                .to eq "[Abstract embargoed until post-graduation] #{presenter.abstract.first}"
            end
          end
        end
      end
    end
  end

  context "embargoes" do
    let(:etd) { FactoryBot.build(:sample_data_with_everything_embargoed) }
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
    let(:partnering_agency) { ["Does not apply (no collaborating organization)"] }
    let(:post_graduation_email) { ['someone@example.org', 'other junk ignored'] }
    let(:submitting_type) { ["Honors Thesis"] }
    let(:research_field) { ['Toxicology'] }
    let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    let :etd do
      Etd.new(title: title, creator: creator, keyword: keyword, degree: degree, department: department,
              school: school, partnering_agency: partnering_agency, submitting_type: submitting_type,
              research_field: research_field, visibility: visibility, post_graduation_email: post_graduation_email,
              requires_permissions: true, other_copyrights: false, patents: true)
    end

    # If the fields require no addition logic for display, you can simply delegate
    # them to the solr document
    it { is_expected.to delegate_method(:degree).to(:solr_document) }
    it { is_expected.to delegate_method(:department).to(:solr_document) }
    it { is_expected.to delegate_method(:school).to(:solr_document) }
    it { is_expected.to delegate_method(:partnering_agency).to(:solr_document) }
    it { is_expected.to delegate_method(:submitting_type).to(:solr_document) }
    it { is_expected.to delegate_method(:research_field).to(:solr_document) }
    it { is_expected.to delegate_method(:requires_permissions).to(:solr_document) }
    it { is_expected.to delegate_method(:other_copyrights).to(:solr_document) }
    it { is_expected.to delegate_method(:patents).to(:solr_document) }

    describe '#post_graduation_email' do
      it 'returns a single string' do
        expect(presenter.post_graduation_email).to eq 'someone@example.org'
      end
    end

    describe '#permission_badge' do
      it 'shows Open Access' do
        expect(presenter.permission_badge).to include 'Open Access'
      end

      context 'when under embargo' do
        subject(:etd) do
          FactoryBot.create(:tomorrow_expiration,
                            files_embargoed: false,
                            toc_embargoed:   false)
        end

        it 'is under embargo' do
          expect(presenter.permission_badge).to include 'All Restricted'
        end

        it 'reflects file level embargo' do
          etd.visibility = VisibilityTranslator::FILES_EMBARGOED
          expect(presenter.permission_badge).to include 'Files'
        end

        it 'reflects toc level embargo' do
          etd.visibility = VisibilityTranslator::TOC_EMBARGOED
          expect(presenter.permission_badge).to include 'ToC'
        end
      end
    end
  end

  context 'with an expired embargo' do
    let(:etd) do
      FactoryBot.build(:etd,
                       table_of_contents: [FFaker::Lorem.paragraph],
                       abstract: [FFaker::Lorem.paragraph],
                       degree_awarded: 13.months.ago,
                       files_embargoed:    true,
                       toc_embargoed:      true,
                       abstract_embargoed: true,
                       embargo: FactoryBot.create(:embargo, embargo_release_date: 1.month.ago))
    end

    it 'is open to all' do
      expect(presenter.permission_badge).to include 'Open'
    end

    it 'does not embargo files' do
      expect(presenter.files_embargo_check).to be_nil
    end

    it 'dos not embargo toc' do
      expect(presenter.toc_with_embargo_check).not_to include 'under embargo'
    end

    it 'does not embargo abstract' do
      expect(presenter.abstract_with_embargo_check).not_to include 'under embargo'
    end
  end

  describe '#department_or_specialty' do
    it 'returns "Specialty" for the nursing school' do
      etd.school = ['Nell Hodgson Woodruff School of Nursing']
      expect(presenter.department_or_specialty).to eq 'Specialty'
    end

    it 'returns "Department" when school is not nursing' do
      etd.school = ['Any other school']
      expect(presenter.department_or_specialty).to eq 'Department'
    end
  end
end
