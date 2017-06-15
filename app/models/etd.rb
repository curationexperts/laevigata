# Generated via
#  `rails generate hyrax:work Etd`
class Etd < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include ::Hyrax::BasicMetadata
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }
  self.human_readable_type = 'Etd'

  after_initialize :set_defaults, unless: :persisted?

  def set_defaults
    self.degree_granting_institution = "http://id.loc.gov/vocabulary/organizations/geu"
    self.rights_statement =
      "Permission granted by the author to include this "                      \
      "thesis or dissertation in this repository. All rights reserved by the " \
      "author. Please contact the author for information regarding the "       \
      "reproduction and use of this thesis or dissertation."
  end

  def hidden?
    return false unless hidden
    true
  end

  # Boolean
  property :hidden, predicate: "http://emory.edu/local/hidden", multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  # should always be Emory University (http://id.loc.gov/vocabulary/organizations/geu)
  property :degree_granting_institution, predicate: "http://id.loc.gov/vocabulary/relators/dgg", multiple: false

  property :department, predicate: "http://vivoweb.org/ontology/core#AcademicDepartment" do |index|
    index.as :stored_searchable, :facetable
  end

  property :school, predicate: "http://vivoweb.org/ontology/core#School" do |index|
    index.as :stored_searchable, :facetable
  end

  property :subfield, predicate: "http://vivoweb.org/ontology/core#majorField" do |index|
    index.as :stored_searchable, :facetable
  end

  property :degree, predicate: "http://vivoweb.org/ontology/core#AcademicDegree" do |index|
    index.as :stored_searchable, :facetable
  end

  property :partnering_agency, predicate: "http://id.loc.gov/vocabulary/relators/ctb" do |index|
    index.as :stored_searchable
  end

  property :submitting_type, predicate: "http://www.europeana.eu/schemas/edm/hasType" do |index|
    index.as :stored_searchable
  end

  property :research_field, predicate: ::RDF::Vocab::DC.subject do |index|
    index.as :stored_searchable, :facetable
  end

  property :rights_statement, predicate: "http://purl.org/dc/elements/1.1/rights", multiple: false

  property :committee_chair, predicate: "http://id.loc.gov/vocabulary/relators/ths", class_name: "CommitteeMember"

  property :committee_members, predicate: "http://id.loc.gov/vocabulary/relators/rev", class_name: "CommitteeMember"

  # TODO: The following properties are placeholders and need to be edited to hold correct predicates and indexes

  property :graduation_date, predicate: "http://vivoweb.org/ontology/core#AcademicDepartment" do |index|
    index.as :stored_searchable, :facetable
  end

  property :post_graduation_email, predicate: "http://vivoweb.org/ontology/core#AcademicDepartment" do |index|
    index.as :stored_searchable, :facetable
  end
end
