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
end
