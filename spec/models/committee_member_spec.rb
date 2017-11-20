# frozen_string_literal: true

require "rails_helper"

describe CommitteeMember do
  let(:name)  { "Smith, Jane" }
  let(:netid) { "jsmith" }
  let(:affiliation) { "Emory University" }
  let(:etd) { FactoryBot.build(:etd) }

  context "a new committee member" do
    let(:committee_member) { etd.committee_members.build }

    it "can set a name" do
      committee_member.name = [name]
      expect(committee_member.name).to eq [name]
    end
    it "can set an affiliation" do
      committee_member.affiliation = [affiliation]
      expect(committee_member.affiliation).to eq [affiliation]
    end
    it "can set a netid" do
      committee_member.netid = [netid]
      expect(committee_member.netid).to eq [netid]
    end
  end
end
