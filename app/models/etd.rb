# Generated via
#  `rails generate hyrax:work Etd`
class Etd < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include ::Hyrax::BasicMetadata
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }
  self.human_readable_type = 'Etd'
  property :school, predicate: "http://vivoweb.org/ontology/core#School" do |index|
    index.as :stored_searchable, :facetable
  end
  property :department, predicate: "http://vivoweb.org/ontology/core#AcademicDepartment" do |index|
    index.as :stored_searchable, :facetable
  end
  property :degree, predicate: "http://vivoweb.org/ontology/core#AcademicDegree" do |index|
    index.as :stored_searchable, :facetable
  end
  property :partnering_agency, predicate: "http://id.loc.gov/vocabulary/relators/ctb" do |index|
    index.as :stored_searchable
  end
end
