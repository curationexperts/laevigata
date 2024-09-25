# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'

RSpec.describe Hyrax::EtdForm do
  subject { form }
  let(:etd)     { build(:etd) }
  let(:ability) { Ability.new(nil) }
  let(:request) { nil }
  let(:form)    { described_class.new(etd, ability, request) }

  before do
    # Don't run jobs during specs. Travis doesn't have fits installed, so these would fail during CI.
    allow(CharacterizeJob).to receive(:perform_later)
    allow(CreateDerivativesJob).to receive(:perform_later)
  end

  describe "::terms" do
    subject { described_class }
    its(:terms) { is_expected.to include(:title) }
    its(:terms) { is_expected.to include(:department) }
    its(:terms) { is_expected.to include(:school) }
    its(:terms) { is_expected.to include(:degree) }
    its(:terms) { is_expected.to include(:subfield) }
    its(:terms) { is_expected.to include(:partnering_agency) }
    its(:terms) { is_expected.to include(:research_field) }
    its(:terms) { is_expected.to include(:submitting_type) }
  end

  describe "editing an ETD" do
    context 'when removing a subfield' do
      let(:form_params) { { "creator" => ['Joey'] } }
      let(:sanitized_params) { { "creator" => ['Joey'], "subfield" => nil } }
      it "gives Hyrax what it needs to execute the removal" do
        allow(Hyrax::Forms::WorkForm).to receive(:sanitize_params).with(form_params)

        described_class.sanitize_params(form_params)

        expect(form_params).to eq(sanitized_params)
      end
    end
  end

  describe "#primary_pdf_name" do
    subject { form.primary_pdf_name }

    let(:depositor) do
      u = User.new(uid: FFaker::Internet.user_name, ppid: Noid::Rails::Service.new.mint, display_name: 'Joey')
      u.save
      u
    end
    let(:etd) { build(:etd, depositor: depositor.user_key) }

    before do
      etd_factory = EtdFactory.new
      etd_factory.etd = etd
      etd_factory.primary_pdf_file = "#{fixture_path}/joey/joey_thesis.pdf"
      etd_factory.attach_primary_pdf_file
      etd.save
    end

    it { is_expected.to eq 'joey_thesis.pdf' }
  end

  describe "#supplemental_files" do
    subject(:supp_files) { form.supplemental_files }

    context "ETD with supplemental files" do
      let(:etd) { build(:etd, ordered_members: [supp_file_1, supp_file_2]) }
      let(:supp_file_1) { build(:supplemental_file_set, title: ['SF1']) }
      let(:supp_file_2) { build(:supplemental_file_set, title: ['SF2']) }

      context "an existing record" do
        before { etd.save! }

        it "returns supplemental files in order" do
          expect(supp_files).to eq [supp_file_1, supp_file_2]
        end
      end
    end

    context "ETD with no supplemental files attached" do
      it { is_expected.to eq [] }
    end
  end

  describe "#cm_affiliation_type" do
    subject { form.cm_affiliation_type(affiliation) }

    context 'without a value for affiliation' do
      let(:affiliation) { nil }
      it { is_expected.to eq 'Emory Committee Member' }
    end

    context 'when value for affiliation is empty' do
      let(:affiliation) { [''] }
      it { is_expected.to eq 'Emory Committee Member' }
    end

    context 'when affiliation is set to Emory' do
      let(:affiliation) { ['Emory University'] }
      it { is_expected.to eq 'Emory Committee Member' }
    end

    context 'when affiliation is set to Non-Emory' do
      let(:affiliation) { ['Some Other University'] }
      it { is_expected.to eq 'Non-Emory Committee Member' }
    end
  end

  describe "#cc_affiliation_type" do
    subject { form.cc_affiliation_type(affiliation) }

    context 'without a value for affiliation' do
      let(:affiliation) { nil }
      it { is_expected.to eq 'Emory Committee Chair' }
    end

    context 'when value for affiliation is empty' do
      let(:affiliation) { [''] }
      it { is_expected.to eq 'Emory Committee Chair' }
    end

    context 'when affiliation is set to Emory' do
      let(:affiliation) { ['Emory University'] }
      it { is_expected.to eq 'Emory Committee Chair' }
    end

    context 'when affiliation is set to Non-Emory' do
      let(:affiliation) { ['Some Other University'] }
      it { is_expected.to eq 'Non-Emory Committee Chair' }
    end
  end
end
