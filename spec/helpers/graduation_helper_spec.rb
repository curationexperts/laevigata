# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GraduationHelper, type: :helper do
  context "calculating embargo_release_date" do
    it "can interpret a length of '6 months'" do
      e = described_class.embargo_length_to_embargo_release_date(Time.zone.today, "6 months")
      expect(e).to eq Time.zone.today + 6.months
    end
    it "can interpret a length of '3 years'" do
      e = described_class.embargo_length_to_embargo_release_date(Time.zone.today, "3 years")
      expect(e).to eq Time.zone.today + 3.years
    end
    it "can interpret a length of 'None - open access immediately'" do
      e = described_class.embargo_length_to_embargo_release_date(Time.zone.today, "None - open access immediately")
      expect(e).to be <= Time.zone.today
    end
  end
end
