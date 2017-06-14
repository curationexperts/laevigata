# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'

RSpec.describe Etd do
  context "#hidden?" do
    let(:etd) { FactoryGirl.create(:etd) }
    context "with a new ETD" do
      it "is not hidden when it is first created" do
        expect(etd.hidden?).to eq false
      end
      it "can be set to true" do
        etd.hidden = true
        expect(etd.hidden?).to eq true
      end
    end
  end

  context "committee_chair" do
    let(:etd) { FactoryGirl.create(:etd) }
    it "has a committee_chair which is a Faculty object" do
      etd.committee_chair = [Faculty.new(name: "Smith, Jane", affiliation: "Emory University", netid: "jsmith")]
      expect(etd.committee_chair.first).to be_instance_of Faculty
      expect(etd.committee_chair.first.name.first).to eq "Smith, Jane"
    end
  end

  context "committee_members" do
    let(:etd) { FactoryGirl.create(:etd) }
    it "has committee_members which are Faculty objects" do
      etd.committee_members = [Faculty.new(name: "Doe, Janet", affiliation: "Emory University", netid: "jdoe"), Faculty.new(name: "Cardinal, Leland", affiliation: "Stanford University", netid: nil)]
      expect(etd.committee_members.first).to be_instance_of Faculty
    end
  end

  describe "#degree" do
    subject { described_class.new }
    let(:degree) { "MS" }
    context "with a new ETD" do
      its(:degree) { is_expected.to be_empty }
    end
    context "with an existing ETD that has a degree defined" do
      subject do
        described_class.create.tap do |etd|
          etd.degree = [degree]
        end
      end
      its(:degree) { is_expected.to eq([degree]) }
    end
  end

  describe "#partnering_agency" do
    subject { described_class.new }
    let(:partnering_agency) { ["Does not apply (no collaborating organization)"] }
    context "with a new ETD" do
      its(:partnering_agency) { is_expected.to be_empty }
    end
    context "with an existing ETD that has a partnering agency defined" do
      subject do
        described_class.create.tap do |etd|
          etd.partnering_agency = partnering_agency
        end
      end
      its(:partnering_agency) { is_expected.to eq(partnering_agency) }
    end
  end

  describe "#submitting_type" do
    subject { described_class.new }
    let(:submitting_type) { ["Honors Thesis"] }
    context "with a new ETD" do
      its(:submitting_type) { is_expected.to be_empty }
    end
    context "with an existing ETD that has a submitting work defined" do
      subject do
        described_class.create.tap do |etd|
          etd.submitting_type = submitting_type
        end
      end
      its(:submitting_type) { is_expected.to eq(submitting_type) }
    end
  end

  describe "#department" do
    subject { described_class.new }
    context "with a new ETD" do
      its(:department) { is_expected.to be_empty }
    end

    context "with an existing ETD that has a department defined" do
      subject do
        described_class.create.tap do |etd|
          etd.department = ["Religion"]
        end
      end

      its(:department) { is_expected.to eq(["Religion"]) }
    end
  end

  describe "#school" do
    subject { described_class.new }
    let(:school) { "Laney Graduate School" }
    context "with a new ETD" do
      its(:school) { is_expected.to be_empty }
    end
    context "with an existing ETD that has a school defined" do
      subject do
        described_class.create.tap do |etd|
          etd.school = [school]
        end
      end
      its(:school) { is_expected.to eq([school]) }
    end
  end

  describe "#subfield" do
    subject { described_class.new }
    let(:subfield) { "Ethics and Society" }
    context "with a new ETD" do
      its(:subfield) { is_expected.to be_empty }
    end
    context "with an existing ETD that has a subfield defined" do
      subject do
        described_class.create.tap do |etd|
          etd.subfield = [subfield]
        end
      end
      its(:subfield) { is_expected.to eq([subfield]) }
    end
  end

  describe "#research_field" do
    subject { described_class.new }
    let(:research_field) { ['0383'] }

    context "with a new ETD" do
      its(:research_field) { is_expected.to be_empty }
    end

    context "with an existing ETD that has a research field defined" do
      subject do
        described_class.create.tap do |etd|
          etd.research_field = research_field
        end
      end
      its(:research_field) { is_expected.to eq(research_field) }
    end
  end

  describe "#committee_chair" do
    subject { described_class.new }
    let(:committee_chair) { ['383'] }

    context "with a new ETD" do
      its(:committee_chair) { is_expected.to be_empty }
    end

    context "with an existing ETD that has a committee chair field defined" do
      subject do
        described_class.create.tap do |etd|
          etd.committee_chair = committee_chair
        end
      end
      its(:committee_chair) { is_expected.to eq(committee_chair) }
    end
  end

  describe "#committee_members" do
    subject { described_class.new }
    let(:committee_members) { ['383'] }

    context "with a new ETD" do
      its(:committee_members) { is_expected.to be_empty }
    end

    context "with an existing ETD that has a committee members field defined" do
      subject do
        described_class.create.tap do |etd|
          etd.committee_members = committee_members
        end
      end
      its(:committee_members) { is_expected.to eq(committee_members) }
    end
  end

  # An ETD should always have a hidden metadata field saying that the degree_granting_institution is Emory
  describe "#degree_granting_institution" do
    subject { described_class.new }
    context "with a new ETD" do
      its(:degree_granting_institution) { is_expected.to eq "http://id.loc.gov/vocabulary/organizations/geu" }
    end
  end
end
