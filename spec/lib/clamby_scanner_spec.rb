require 'rails_helper'
require 'clamby_scanner'

RSpec.describe ClambyScanner do
  let(:infected_file) { Rails.root.join('spec', 'fixtures', 'virus_checking', 'virus_check.txt').to_s }
  let(:clean_file)    { Rails.root.join('spec', 'fixtures', 'miranda', 'miranda_thesis.pdf').to_s }

  describe "Clamby" do
    before do
      # Stub Clamby to return true if filename includes "virus"
      # in environments without ClamAV installed - e.g. CircleCI
      Clamby.configure(error_clamscan_missing: false, output_level: 'off')
      unless Clamby.scanner_exists?
        class_double("Clamby").as_stubbed_const
        allow(Clamby).to receive(:virus?) { |args| args.match?(/virus/i) }
      end
    end

    it 'detects viruses' do
      expect(described_class.infected?(infected_file)).to be true
    end

    it 'passes clean files' do
      expect(described_class.infected?(clean_file)).to be false
    end
  end

  describe "functionality" do
    # ClambyScanner can be removed once we're running a more recent version of hydra-works
    it 'is handled natively in hydra-works >= 2.0.0' do
      pending 'hydra-works >= v2.0.0'
      native = Gem::Version.new(Hydra::Works::VERSION) >= Gem::Version.new('2.0.0')
      expect(native).to be true
    end
  end
end
