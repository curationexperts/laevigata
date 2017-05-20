require 'spec_helper'

describe PartnersService do
  describe "select_all_options" do
    subject { described_class.select_all_options }

    it "has a select list" do
      expect(subject.first).to eq ["Does not apply (no collaborating organization)", "Does not apply (no collaborating organization)"]
      expect(subject.size).to eq 17
    end
  end

  describe "label" do
    subject { described_class.label("Religious-based organization") }

    it { is_expected.to eq 'Religious-based organization' }
  end
end
