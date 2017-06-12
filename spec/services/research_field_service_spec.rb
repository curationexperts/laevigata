require 'spec_helper'

describe ResearchFieldService do
  let(:research_field_service) { described_class.new }

  describe "select_all_options" do
    subject(:research_field_options) { research_field_service.select_all_options }

    it "has a select list" do
      expect(research_field_options.first).to eq ['Accounting', '0272']
      expect(research_field_options).to include ['Art criticism', '0365']
      expect(research_field_options).to include ['Clerical studies', '0319']
      expect(research_field_options).to include ['Dentistry', '0567']
      expect(research_field_options).to include ['French Canadian culture', '0482']
      expect(research_field_options).to include ['Morphology', '0287']
      expect(research_field_options).to include ['Social work', '0452']
      expect(research_field_options).to include ['Veterinary medicine', '0778']
      expect(research_field_options.size).to eq 409
    end
  end

  describe "label" do
    subject { research_field_service.label('0383') }

    it { is_expected.to eq 'Toxicology' }
  end
end
