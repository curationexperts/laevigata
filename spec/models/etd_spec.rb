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

  describe "#degree" do
    subject { described_class.new }
    let(:degree) { "Bachelor of Arts with Honors" }
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
          etd.department = ["Department of Russian and East Asian Languages and Cultures"]
        end
      end

      its(:department) { is_expected.to eq(["Department of Russian and East Asian Languages and Cultures"]) }
    end
  end

  describe "#school" do
    subject { described_class.new }
    let(:school) { "Emory College of Arts and Sciences" }
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
    let(:committee_chair) { ['Adam'] }

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
    let(:committee_members) { ['John'] }

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
