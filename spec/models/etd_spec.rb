# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'

RSpec.describe Etd do
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

  # An ETD should always have a hidden metadata field saying that the degree_granting_institution is Emory
  describe "#degree_granting_institution" do
    subject { described_class.new }
    context "with a new ETD" do
      its(:degree_granting_institution) { is_expected.to eq "http://id.loc.gov/vocabulary/organizations/geu" }
    end
  end
end
