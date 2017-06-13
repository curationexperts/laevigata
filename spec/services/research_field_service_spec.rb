require 'spec_helper'

describe ResearchFieldService do
  let(:research_field_service) { described_class.new }

  describe "select_all_options" do
    subject(:research_field_options) { research_field_service.select_all_options }

    it "has a select list" do
      expect(research_field_options.first).to eq ['0272', 'Accounting']
      expect(research_field_options).to include ['0365', 'Art criticism']
      expect(research_field_options).to include ['0319', 'Clerical studies']
      expect(research_field_options).to include ['0567', 'Dentistry']
      expect(research_field_options).to include ['0482', 'French Canadian culture']
      expect(research_field_options).to include ['0287', 'Morphology']
      expect(research_field_options).to include ['0452', 'Social work']
      expect(research_field_options).to include ['0778', 'Veterinary medicine']
      expect(research_field_options.size).to eq 409
    end
  end

  describe "label" do
    subject { research_field_service.label('Toxicology') }

    it { is_expected.to eq '0383' }
  end
end
