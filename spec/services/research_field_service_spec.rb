require 'rails_helper'

describe ResearchFieldService do
  let(:research_field_service) { described_class.new }

  describe "select_all_options" do
    subject(:research_field_options) { research_field_service.select_all_options }

    it "has a select list" do
      expect(research_field_options.first).to eq ['0367', 'Aeronomy']
      expect(research_field_options).to include ['0365', 'Art Criticism']
      expect(research_field_options).to include ['0319', 'Religion, Clergy']
      expect(research_field_options).to include ['0567', 'Health Sciences, Dentistry']
      expect(research_field_options).to include ['0482', 'French Canadian Culture']
      expect(research_field_options).to include ['0287', 'Biology, Anatomy']
      expect(research_field_options).to include ['0452', 'Social Work']
      expect(research_field_options).to include ['0778', 'Biology, Veterinary Science']
      expect(research_field_options.size).to be >= 410
    end
  end

  describe "select_active_ids" do
    it { expect(research_field_service.select_active_ids).to include ['Aeronomy', 'Aeronomy'] }
    it { expect(research_field_service.select_active_ids).to include ['Social Work', 'Social Work'] }
    it { expect(research_field_service.select_active_ids).not_to include ['Biology, Radiation', 'Biology, Radiation'] }
  end

  describe "label" do
    subject { research_field_service.label('Art Criticism') }

    it { is_expected.to eq '0365' }
  end
end
