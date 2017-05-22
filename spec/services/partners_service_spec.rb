require 'spec_helper'

describe PartnersService do
  describe "select_all_options" do
    subject(:etd) { described_class.select_all_options }

    it "has a select list" do
      expect(etd.first).to eq ["Does not apply (no collaborating organization)", "Does not apply (no collaborating organization)"]
      expect(etd.size).to eq 17
    end
  end

  describe "label" do
    subject(:etd) { described_class.label("Religious-based organization") }

    it { is_expected.to eq 'Religious-based organization' }
  end
end
