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
end
