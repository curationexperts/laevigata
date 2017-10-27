# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'

RSpec.describe Hyrax::EtdForm do
  subject { form }
  let(:etd)     { build(:etd) }
  let(:ability) { Ability.new(nil) }
  let(:request) { nil }
  let(:form)    { described_class.new(etd, ability, request) }

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

  describe "#primary_pdf_name" do
    subject { form.primary_pdf_name }

    let(:depositor) do
      u = User.new(uid: FFaker::Internet.user_name, ppid: ActiveFedora::Noid::Service.new.mint, display_name: 'Joey')
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

  # Figure out the correct state for the 'No Supplemental Files' checkbox on the ETD form.
  describe "#no_supplemental_files" do
    subject { form.no_supplemental_files }

    context "ETD with no supplemental files attached" do
      context "a new record" do
        it { is_expected.to eq false }
      end

      # If we are rendering the edit form for an existing ETD,
      # and the ETD doesn't have any supplemental files,
      # the form should pre-check the 'No Supplemental Files'
      # checkbox, since that is the current state.
      context "an existing record" do
        before { etd.save! }
        it { is_expected.to eq true }
      end
    end

    context "ETD with supplemental files" do
      let(:etd) { build(:etd, members: [supp_file]) }
      let(:supp_file) { build(:supplemental_file_set) }

      context "a new record" do
        it { is_expected.to eq false }
      end

      context "an existing record" do
        before { etd.save! }
        it { is_expected.to eq false }
      end
    end
  end

  # Figure out the correct state for the 'No Embargo' checkbox on the ETD form.
  describe "#no_embargoes" do
    subject { form.no_embargoes }

    context "ETD with no embargo" do
      context "a new record" do
        it { is_expected.to eq false }
      end

      context "an existing record" do
        before { etd.save! }
        it { is_expected.to eq true }
      end
    end

    context "ETD with embargo" do
      let(:etd) { build(:sample_data_with_only_files_embargoed) }

      context "a new record" do
        it { is_expected.to eq false }
      end

      context "an existing record" do
        before { etd.save! }
        it { is_expected.to eq false }
      end
    end
  end

  describe "#selected_embargo_type" do
    subject { form.selected_embargo_type }

    context "a new record" do
      it { is_expected.to be_nil }
    end

    context "existing ETD with no embargo" do
      before { etd.save! }
      it { is_expected.to be_nil }
    end

    context "existing ETD with only files embargoed" do
      let(:etd) { build(:sample_data_with_only_files_embargoed) }
      before { etd.save! }
      it { is_expected.to eq '[:files_embargoed]' }
    end

    context "existing ETD with TOC embargoed" do
      let(:etd) { build(:etd, toc_embargoed: true, abstract_embargoed: false) }
      before { etd.save! }
      it { is_expected.to eq '[:files_embargoed, :toc_embargoed]' }
    end

    context "existing ETD with Abstract embargoed" do
      let(:etd) { build(:etd, abstract_embargoed: true) }
      before { etd.save! }
      it { is_expected.to eq '[:files_embargoed, :toc_embargoed, :abstract_embargoed]' }
    end

    # It looks like the embargo fields get stored as strings
    # instead of booleans if you create an ETD using the UI.
    # Since this code is already in production, to avoid having
    # to do a data migration, I don't want to convert these
    # fields to strictly boolean, so we need to make sure it
    # works with either strings or booleans.
    context "existing ETD with TOC embargoed (string values)" do
      let(:etd) { build(:etd, toc_embargoed: 'true', abstract_embargoed: 'false') }
      before { etd.save! }
      it { is_expected.to eq '[:files_embargoed, :toc_embargoed]' }
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
