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
  end

  property :degree, predicate: "http://vivoweb.org/ontology/core#AcademicDegree" do |index|
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
end
