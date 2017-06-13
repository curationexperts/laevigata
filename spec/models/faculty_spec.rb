# frozen_string_literal: true

require "rails_helper"

describe Faculty do
  describe "properties" do
    let(:name)  { "Smith, Jane" }
    let(:netid) { "jsmith" }
    let(:affiliation) { "Emory University" }
    let(:faculty) { described_class.new(name: name, affiliation: affiliation, netid: netid) }

    it "has a name" do
      expect(faculty.name).to eq [name]
    end
    it "has a netid" do
      expect(faculty.netid).to eq [netid]
    end
    it "has an affiliation" do
      expect(faculty.affiliation).to eq [affiliation]
    end
  end
end
