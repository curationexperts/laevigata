require 'rails_helper'

RSpec.describe Hyrax::BiostatisticsService do
  before do
    # Configure QA to use fixtures
    qa_fixtures = { local_path: File.expand_path('config/authorities') }
    allow(Qa::Authorities::Local).to receive(:config).and_return(qa_fixtures)
  end

  let(:service) { described_class.new }

  describe "#select_all_options" do
    it "has a select list" do
      expect(service.select_all_options).to include(["Public Health Informatics - MSPH", "Public Health Informatics"])
    end
  end
end
