# frozen_string_literal: true

require "rails_helper"

describe CommitteeMember do
  describe "properties" do
    let(:name)  { "Smith, Jane" }
    let(:netid) { "jsmith" }
    let(:affiliation) { "Emory University" }
    let(:committee_member) { described_class.new(name: name, affiliation: affiliation, netid: netid) }

    it "has a name" do
      expect(committee_member.name).to eq [name]
    end
    it "has a netid" do
      expect(committee_member.netid).to eq [netid]
    end
    it "has an affiliation" do
      expect(committee_member.affiliation).to eq [affiliation]
    end
  end
end
