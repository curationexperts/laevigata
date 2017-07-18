# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'

RSpec.describe Etd do
  context "#hidden?" do
    let(:etd) { FactoryGirl.build(:etd) }
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

  context "determining admin set" do
    let(:etd) { FactoryGirl.build(:etd) }
    let(:epidemiology_admin_set) { FactoryGirl.create(:admin_set, title: ["Epidemiology"]) }
    it "assigns the laney admin set when the school is laney" do
      etd.school = ["Laney Graduate School"]
      expect(etd.determine_admin_set).to eq "Laney Graduate School"
    end
    it "assigns the candler admin set when the school is candler" do
      etd.school = ["Candler School of Theology"]
      expect(etd.determine_admin_set).to eq "Candler School of Theology"
    end
    it "assigns the emory college admin set when the school is emory college" do
      etd.school = ["Emory College"]
      expect(etd.determine_admin_set).to eq "Emory College"
    end
    it "assigns according to department for Rollins" do
      etd.school = ["Rollins School of Public Health"]
      etd.department = ["Epidemiology"]
      expect(etd.determine_admin_set).to eq "Epidemiology"
    end
    it "raises an error if it can't find the admin set in the config" do
      etd.school = ["Fake School"]
      expect { etd.determine_admin_set }.to raise_error(RuntimeError, /Cannot find admin set config/)
    end
    it "assigns the admin set" do
      expect(epidemiology_admin_set.title).to contain_exactly("Epidemiology")
      etd.department = ["Epidemiology"]
      etd.assign_admin_set
      expect(etd.admin_set.title).to contain_exactly("Epidemiology")
    end
  end

  context "three kinds of embargo" do
    let(:etd) { FactoryGirl.build(:etd) }
    it "#files_embargoed" do
      expect(etd.files_embargoed).to eq nil
      etd.files_embargoed = true
      expect(etd.files_embargoed).to eq true
    end
    it "#abstract_embargoed" do
      expect(etd.abstract_embargoed).to eq nil
      etd.abstract_embargoed = true
      expect(etd.abstract_embargoed).to eq true
    end
    it "#toc_embargoed" do
      expect(etd.toc_embargoed).to eq nil
      etd.toc_embargoed = true
      expect(etd.toc_embargoed).to eq true
    end
  end

  context "embargo length" do
    let(:etd) { FactoryGirl.build(:etd) }
    it "has an embargo length" do
      etd.embargo_length = "6 months"
      expect(etd.resource.dump(:ttl)).to match(/purl.org\/spar\/fabio\/hasEmbargoDuration/)
      expect(etd.embargo_length).to eq "6 months"
    end
  end

  context "abstract" do
    let(:etd) { FactoryGirl.build(:etd) }
    it "has an abstract" do
      etd.abstract = ["Mlkshk mixtape aesthetic artisan scenester wolf 8-bit Four Loko."]
      expect(etd.resource.dump(:ttl)).to match(/purl.org\/dc\/terms\/abstract/)
      expect(etd.abstract.first).to match(/^Mlkshk/)
    end
  end

  context "table of contents" do
    let(:etd) { FactoryGirl.build(:etd) }
    it "has a table_of_contents" do
      etd.table_of_contents = ["Irony Austin seitan vegan skateboard +1 sartorial wolf McSweeney's."]
      expect(etd.resource.dump(:ttl)).to match(/purl.org\/dc\/terms\/tableOfContents/)
      expect(etd.table_of_contents.first).to match(/^Irony/)
    end
  end

  context "keyword" do
    let(:etd) { FactoryGirl.build(:etd) }
    it "has keywords" do
      etd.keyword = ["Irony", "Austin", "seitan"]
      expect(etd.resource.dump(:ttl)).to match(/schema.org\/keywords/)
      expect(etd.keyword.include?("Irony")).to be true
    end
  end

  context "legacy_id" do
    let(:etd) { FactoryGirl.build(:etd) }
    it "has several legacy ids" do
      etd.legacy_id = ["emory:rpj8w", "emory:rpj91"]
      expect(etd.resource.dump(:ttl)).to match(/id.loc.gov\/vocabulary\/identifiers\/local/)
      expect(etd.legacy_id.include?("emory:rpj91")).to be true
    end
  end

  context "graduation_year" do
    let(:etd) { FactoryGirl.build(:etd) }
    it "has graduation_year" do
      etd.graduation_year = "2007"
      expect(etd.resource.dump(:ttl)).to match(/purl.org\/dc\/terms\/issued/)
      expect(etd.graduation_year).to eq "2007"
    end
  end

  # An ETD should always have the Emory default rights statement
  context "rights_statement" do
    let(:etd) { described_class.new }
    it "always has the Emory default rights statement" do
      expect(etd.rights_statement.first).to match(/^Permission granted by the author to include this thesis/)
    end
  end

  context "committee members" do
    let(:etd) { FactoryGirl.create(:ateer_etd) }
    it "has a committee_chair which is a CommitteeMember object" do
      expect(etd.committee_chair.first).to be_instance_of CommitteeMember
    end
    it "has committee_chair_name indexed so its accessible from the presenter" do
      expect(etd.committee_chair_name.count).to eq 1
      expect(etd.committee_chair_name.include?('Treadway, Michael T')).to eq true
    end
    it "has committee_members which are CommitteeMember objects" do
      expect(etd.committee_members.first).to be_instance_of CommitteeMember
      expect(etd.committee_members.count).to eq 2
    end
    it "has committee_members_names indexed so they're accessible from the presenter" do
      expect(etd.committee_members_names.count).to eq 2
      expect(etd.committee_members_names.include?("Craighead, W Edward")).to eq true
    end
  end

  context "author name" do
    let(:etd) { FactoryGirl.build(:etd) }
    it "has a creator with the expected predicate" do
      etd.creator = ["Wayne, John"]
      expect(etd.resource.dump(:ttl)).to match(/id.loc.gov\/vocabulary\/relators\/aut/)
    end
  end

  context "submitting_type" do
    let(:etd) { FactoryGirl.build(:etd) }
    it "has a submitting_type with the expected predicate" do
      etd.submitting_type = ["Master's Thesis"]
      expect(etd.submitting_type.first).to eq "Master's Thesis"
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

  context "the three intellectual property questions" do
    let(:etd) { FactoryGirl.build(:etd) }
    it "has an answer about permissions" do
      etd.copyright_question_one = true
      expect(etd.resource.dump(:ttl)).to match(/www.w3.org\/2004\/02\/skos\/core\#note_permissions/)
      expect(etd.copyright_question_one).to eq true
    end
    it "has an answer about copyright" do
      etd.copyright_question_two = true
      expect(etd.resource.dump(:ttl)).to match(/www.w3.org\/2004\/02\/skos\/core\#note_copyrights/)
      expect(etd.copyright_question_two).to eq true
    end
    it "has an answer about patents" do
      etd.copyright_question_three = true
      expect(etd.resource.dump(:ttl)).to match(/www.w3.org\/2004\/02\/skos\/core\#note_patents/)
      expect(etd.copyright_question_three).to eq true
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

  describe "#research_field and #research_field_id" do
    subject(:etd) { described_class.new }
    let(:research_field) { ['Health Sciences, Toxicology'] }

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
end
