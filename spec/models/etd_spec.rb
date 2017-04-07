# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'

RSpec.describe Etd do
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
end
