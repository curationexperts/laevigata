require 'spec_helper'

describe ResearchFieldService do
  let(:research_field_service) { described_class.new }

  describe "select_all_options" do
    subject(:research_field_options) { research_field_service.select_all_options }

    it "has a select list" do
      expect(research_field_options.first).to eq ['Veterinary medicine', '0778']
      expect(research_field_options).to include ['Dentistry', '0567']
      expect(research_field_options.size).to eq 409
    end
  end

  describe "label" do
    subject { research_field_service.label('0383') }

    it { is_expected.to eq 'Toxicology' }
  end
end
