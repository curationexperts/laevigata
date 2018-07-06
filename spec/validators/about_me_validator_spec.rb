require 'rails_helper'

describe AboutMeValidator do
  context "parsed_data method" do
    subject(:about_me_validator) { described_class.new }
    let(:record) { InProgressEtd.new }
    it "returns an empty hash if passed a record without data" do
      expect(about_me_validator.parsed_data(record)).to eq({})
    end
  end
end
