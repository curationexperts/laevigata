# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'

RSpec.describe Etd do
  context "#hidden?" do
    let(:etd) { FactoryGirl.create(:etd) }
    context "with a new ETD" do
      it "is not hidden when it is first created" do
        expect(etd.hidden?).to eq false
      end
      it "can be set to true" do
        etd.hidden = true
        expect(etd.hidden?).to eq true
      end
    end
  end

  context "committee_chair" do
    let(:etd) { FactoryGirl.create(:etd) }
    it "has a committee_chair which is a CommitteeMember object" do
      expect(etd.committee_chair.first).to be_instance_of CommitteeMember
    end
  end

  context "committee_members" do
    let(:etd) { FactoryGirl.create(:etd) }
    it "has committee_members which are CommitteeMember objects" do
      expect(etd.committee_members.first).to be_instance_of CommitteeMember
      expect(etd.committee_members.count).to eq 3
    end
  end

  context "author name" do
    let(:etd) { FactoryGirl.build(:etd) }
    it "has a creator with the expected predicate" do
      expect(etd.resource.dump(:ttl)).to match(/id.loc.gov\/vocabulary\/relators\/aut/)
    end
  end

  context "emails" do
    let(:etd) { FactoryGirl.build(:etd) }
    it "has a primary email with the expected predicate" do
      etd.email = ['lonnie@mcdermott.ca']
      expect(etd.resource.dump(:ttl)).to match(/www.ebu.ch\/metadata\/ontologies\/ebucore\/ebucore\#officeEmailAddress/)
    end
    it "has a post graduation email with the expected predicate" do
      etd.post_graduation_email = ['kandis@robellarkin.info']
      expect(etd.resource.dump(:ttl)).to match(/www.ebu.ch\/metadata\/ontologies\/ebucore\/ebucore\#privateEmailAddress/)
    end
  end

  context "graduation_date" do
    let(:etd) { FactoryGirl.build(:etd) }
    it "has a semester and year" do
      etd.graduation_date = ["Spring 2019"]
      expect(etd.resource.dump(:ttl)).to match(/purl.org\/dc\/terms\/issued/)
      expect(etd.graduation_date).to eq ["Spring 2019"]
    end
  end

  describe "#degree" do
    subject { described_class.new }
    let(:degree) { "MS" }
    context "with a new ETD" do
      its(:degree) { is_expected.to be_empty }
    end
    context "with an existing ETD that has a degree defined" do
      subject do
        described_class.create.tap do |etd|
          etd.degree = [degree]
        end
      end
      its(:degree) { is_expected.to eq([degree]) }
    end
  end

  describe "#partnering_agency" do
    subject { described_class.new }
    let(:partnering_agency) { ["Does not apply (no collaborating organization)"] }
    context "with a new ETD" do
      its(:partnering_agency) { is_expected.to be_empty }
    end
    context "with an existing ETD that has a partnering agency defined" do
      subject do
        described_class.create.tap do |etd|
          etd.partnering_agency = partnering_agency
        end
      end
      its(:partnering_agency) { is_expected.to eq(partnering_agency) }
    end
  end

  describe "#submitting_type" do
    subject { described_class.new }
    let(:submitting_type) { ["Honors Thesis"] }
    context "with a new ETD" do
      its(:submitting_type) { is_expected.to be_empty }
    end
    context "with an existing ETD that has a submitting work defined" do
      subject do
        described_class.create.tap do |etd|
          etd.submitting_type = submitting_type
        end
      end
      its(:submitting_type) { is_expected.to eq(submitting_type) }
    end
  end

  describe "#department" do
    subject { described_class.new }
    context "with a new ETD" do
      its(:department) { is_expected.to be_empty }
    end

    context "with an existing ETD that has a department defined" do
      subject do
        described_class.create.tap do |etd|
          etd.department = ["Religion"]
        end
      end

      its(:department) { is_expected.to eq(["Religion"]) }
    end
  end

  describe "#school" do
    subject { described_class.new }
    let(:school) { "Laney Graduate School" }
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

  describe "#subfield" do
    subject { described_class.new }
    let(:subfield) { "Ethics and Society" }
    context "with a new ETD" do
      its(:subfield) { is_expected.to be_empty }
    end
    context "with an existing ETD that has a subfield defined" do
      subject do
        described_class.create.tap do |etd|
          etd.subfield = [subfield]
        end
      end
      its(:subfield) { is_expected.to eq([subfield]) }
    end
  end

  describe "#title" do
    subject { described_class.new }
    let(:title) { "Cool Etd" }
    context "with a new ETD" do
      its(:title) { is_expected.to be_empty }
    end
    context "with an existing ETD that has a title defined" do
      subject do
        described_class.create.tap do |etd|
          etd.title = [title]
        end
      end
      its(:title) { is_expected.to eq([title]) }
    end
  end

  describe "#language" do
    subject { described_class.new }
    let(:language) { "English" }
    context "with a new ETD" do
      its(:language) { is_expected.to be_empty }
    end
    context "with an existing ETD that has a language defined" do
      subject do
        described_class.create.tap do |etd|
          etd.language = [language]
        end
      end
      its(:language) { is_expected.to eq([language]) }
    end
  end

  describe "#abstract" do
    subject { described_class.new }
    let(:abstract) { "This an amazing abstract" }
    context "with a new ETD" do
      its(:abstract) { is_expected.to be_empty }
    end
    context "with an existing ETD that has a abstract defined" do
      subject do
        described_class.create.tap do |etd|
          etd.abstract = [abstract]
        end
      end
      its(:abstract) { is_expected.to eq([abstract]) }
    end
  end

  describe "#table_of_contents" do
    subject { described_class.new }
    let(:table_of_contents) { "This is my table of contents" }
    context "with a new ETD" do
      its(:table_of_contents) { is_expected.to be_empty }
    end
    context "with an existing ETD that has a table of contents defined" do
      subject do
        described_class.create.tap do |etd|
          etd.table_of_contents = [table_of_contents]
        end
      end
      its(:table_of_contents) { is_expected.to eq([table_of_contents]) }
    end
  end

  describe "#keyword" do
    subject { described_class.new }
    let(:keyword) { "astrology" }
    context "with a new ETD" do
      its(:keyword) { is_expected.to be_empty }
    end
    context "with an existing ETD that has a keyword defined" do
      subject do
        described_class.create.tap do |etd|
          etd.keyword = [keyword]
        end
      end
      its(:keyword) { is_expected.to eq([keyword]) }
    end
  end

  describe "#file_format" do
    subject { described_class.new }
    let(:file_format) { "application/pdf" }
    context "with a new ETD" do
      its(:file_format) { is_expected.to be_empty }
    end
    context "with an existing ETD that has a keyword defined" do
      subject do
        described_class.create.tap do |etd|
          etd.file_format = [file_format]
        end
      end
      its(:file_format) { is_expected.to eq([file_format]) }
    end
  end

  describe "#identifier" do
    subject { described_class.new }
    let(:identifier) { "ID" }
    context "with a new ETD" do
      its(:identifier) { is_expected.to be_empty }
    end
    context "with an existing ETD that has a identifier defined" do
      subject do
        described_class.create.tap do |etd|
          etd.identifier = [identifier]
        end
      end
      its(:identifier) { is_expected.to eq([identifier]) }
    end
  end

  describe "#creator" do
    subject { described_class.new }
    let(:creator) { "ID" }
    context "with a new ETD" do
      its(:creator) { is_expected.to be_empty }
    end
    context "with an existing ETD that has a author defined" do
      subject do
        described_class.create.tap do |etd|
          etd.creator = [creator]
        end
      end
      its(:creator) { is_expected.to eq([creator]) }
    end
  end

  describe "#description" do
    subject { described_class.new }
    let(:description) { "ID" }
    context "with a new ETD" do
      its(:description) { is_expected.to be_empty }
    end
    context "with an existing ETD that has a description defined" do
      subject do
        described_class.create.tap do |etd|
          etd.description = [description]
        end
      end
      its(:description) { is_expected.to eq([description]) }
    end
  end

  describe "#secondary_file_type" do
    subject { described_class.new }
    let(:secondary_file_type) { "Sound" }
    context "with a new ETD" do
      its(:secondary_file_type) { is_expected.to be_empty }
    end
    context "with an existing ETD that has a file type defined" do
      subject do
        described_class.create.tap do |etd|
          etd.secondary_file_type = [secondary_file_type]
        end
      end
      its(:secondary_file_type) { is_expected.to eq([secondary_file_type]) }
    end
  end

  describe "#research_field and #research_field_id" do
    subject(:etd) { described_class.new }
    let(:research_field) { ['Toxicology'] }

    it "is empty when new" do
      expect(etd.research_field).to be_empty
      expect(etd.research_field_id).to be_empty
    end

    it "saves research fields and ids" do
      etd.title = ['Test']
      etd.research_field = research_field
      etd.save!

      expect(etd.research_field).to eq(research_field)
      expect(etd.research_field_id).to eq(['0383'])
    end
  end

  # An ETD should always have a hidden metadata field saying that the degree_granting_institution is Emory
  describe "#degree_granting_institution" do
    subject { described_class.new }
    context "with a new ETD" do
      its(:degree_granting_institution) { is_expected.to eq "http://id.loc.gov/vocabulary/organizations/geu" }
    end
  end

  # An ETD should always have the Emory default rights statement
  describe "#rights_statement" do
    subject { described_class.new }
    context "with a new ETD" do
      its(:rights_statement) { is_expected.to match(/^Permission granted by the author to include this thesis/) }
    end
  end
end
