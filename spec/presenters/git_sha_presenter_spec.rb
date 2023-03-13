require 'rails_helper'

describe GitShaPresenter do
  let(:log_tail)  { 'Branch v3.2.1 (at 60926a839305927323bea05511ca2fbdffac236b) deployed as release 20221012015436 by kevin' }
  let(:rev_parse) { '71a6ad22c344ba485dcd454414fa1e529d641cfb' }
  let(:rev_parse_abbr) { 'my_new_feature_branch' }

  # We need to clear out instance variables for these tests
  # because the methods are memoized and won't re-run otherwise.
  before do
    described_class.instance_variable_set(:@sha, nil)
    described_class.instance_variable_set(:@branch, nil)
    described_class.instance_variable_set(:@last_deployed, nil)
  end

  describe "#sha" do
    example "in production" do
      allow(Rails.env).to receive(:production?).and_return true
      allow(File).to receive(:exist?).with('/opt/laevigata/revisions.log').and_return true
      allow(described_class).to receive(:`).and_return log_tail

      expect(described_class.sha).to eq '60926a839305927323bea05511ca2fbdffac236b'
    end
    example "in development" do
      allow(Rails.env).to receive(:development?).and_return true
      allow(described_class).to receive(:`).and_return rev_parse

      expect(described_class.sha).to eq '71a6ad22c344ba485dcd454414fa1e529d641cfb'
    end
    example "fallback" do
      allow(Rails.env).to receive(:test?).and_return false
      expect(described_class.sha).to eq 'Unknown SHA'
    end
  end

  describe "#branch" do
    example "in production" do
      allow(Rails.env).to receive(:production?).and_return true
      allow(File).to receive(:exist?).with('/opt/laevigata/revisions.log').and_return true
      allow(described_class).to receive(:`).and_return log_tail

      expect(described_class.branch).to eq 'v3.2.1'
    end
    example "in development" do
      allow(Rails.env).to receive(:development?).and_return true
      allow(described_class).to receive(:`).and_return rev_parse_abbr

      expect(described_class.branch).to eq 'my_new_feature_branch'
    end
    example "fallback" do
      allow(Rails.env).to receive(:test?).and_return false

      expect(described_class.branch).to eq 'Unknown branch'
    end
  end

  describe "#last_deployed" do
    example "in production" do
      allow(Rails.env).to receive(:production?).and_return true
      allow(File).to receive(:exist?).with('/opt/laevigata/revisions.log').and_return true
      allow(described_class).to receive(:`).and_return log_tail

      expect(described_class.last_deployed).to eq '12 October 2022'
    end
    example "in other environments" do
      allow(Rails.env).to receive(:production?).and_return false

      expect(described_class.last_deployed).to eq 'Not in deployed environment'
    end
  end
end
