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
    its(:terms) { is_expected.to include(:language) }
    its(:terms) { is_expected.to include(:abstract) }
    its(:terms) { is_expected.to include(:table_of_contents) }
    its(:terms) { is_expected.to include(:keyword) }
    its(:terms) { is_expected.to include(:identifier) }
    its(:terms) { is_expected.to include(:creator) }
    its(:terms) { is_expected.to include(:description) }
    its(:terms) { is_expected.to include(:secondary_file_type) }
  end
end
