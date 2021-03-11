# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GraduationHelper, type: :helper do
  let(:graduation_date) { "2019-08-17" }

  context "with valid embargo_length and graduation_date" do
    it "inteprets month units" do
      byebug
      release_date = described_class.embargo_length_to_embargo_release_date(graduation_date, "6 months")
      expect(release_date).to eq graduation_date.to_datetime + 6.months
    end

    it "interprets year units" do
      release_date = described_class.embargo_length_to_embargo_release_date(graduation_date, "3 years")
      expect(release_date).to eq graduation_date.to_datetime + 3.years
    end

    it "can interpret a length of 'None - open access immediately'" do
      release_date = described_class.embargo_length_to_embargo_release_date(graduation_date, "None - open access immediately")
      expect(release_date).to eq graduation_date
    end
  end

  context "with unexpected values" do
    before(:example) { allow(Rails.logger).to receive(:warn) }

    it "handles exmpty embargo_length as 'None'" do
      embargo_length = ''
      release_date = described_class.embargo_length_to_embargo_release_date(graduation_date, embargo_length)
      expect(release_date).to eq graduation_date
      expect(Rails.logger).to have_received(:warn).with("Treating empty requested_embargo as 'None'")
    end

    it "handles nil embargo_length as 'None'" do
      embargo_length = nil
      release_date = described_class.embargo_length_to_embargo_release_date(graduation_date, embargo_length)
      expect(release_date).to eq graduation_date
      expect(Rails.logger).to have_received(:warn).with("Treating empty requested_embargo as 'None'")
    end

    it "raises an error for random embargo_lengths" do
      embargo_length = 'Four score and seven years'
      expect{ described_class.embargo_length_to_embargo_release_date(graduation_date, embargo_length) }.to raise_error ArgumentError
    end
  end
end
