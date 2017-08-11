require 'workflow_setup'
# Generated via
#  `rails generate hyrax:work Etd`
class Etd < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include ::Hyrax::BasicMetadata
  include ::ProquestBehaviors
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }
  validates :research_field, length: { maximum: 3 }
  self.human_readable_type = 'ETD'

  after_initialize :set_defaults, unless: :persisted?
  before_save :set_research_field_ids, :index_committee_chair_name, :index_committee_members_names

  def set_defaults
    self.degree_granting_institution = "http://id.loc.gov/vocabulary/organizations/geu"
    self.rights_statement =
      ["Permission granted by the author to include this "                      \
      "thesis or dissertation in this repository. All rights reserved by the " \
      "author. Please contact the author for information regarding the "       \
      "reproduction and use of this thesis or dissertation."]
  end

  def set_research_field_ids
    research_field_service = ResearchFieldService.new
    self.research_field_id = research_field.each.map { |f| research_field_service.label(f) }
  rescue KeyError
    Rails.logger.error "Couldn't find research_field_id for #{research_field.inspect}"
  end

  def index_committee_chair_name
    return unless committee_chair && committee_chair.first
    self.committee_chair_name = committee_chair.map { |cc| cc.name.first }
  end

  def index_committee_members_names
    return unless committee_members && committee_members.first
    self.committee_members_names = committee_members.map { |cm| cm.name.first }
  end

  def hidden?
    return false unless hidden
    true
  end

  # Return false until a value is set for degree_awarded, then return true
  def post_graduation?
    return false unless degree_awarded
    true
  end

  # Determine what admin set an ETD should belong to, based on what school and
  # department it belongs to
  # @return [String] the name of an admin set
  def determine_admin_set(school = self.school, department = self.department)
    valid_admin_sets = YAML.safe_load(File.read(WorkflowSetup::DEFAULT_ADMIN_SETS_CONFIG)).keys
    admin_set_determined_by_school = ["Laney Graduate School", "Candler School of Theology", "Emory College"]
    return school.first if admin_set_determined_by_school.include?(school.first) && valid_admin_sets.include?(school.first)
    return department.first if valid_admin_sets.include?(department.first)
    raise "Cannot find admin set config where school = #{school.first} and department = #{department.first}"
  end

  # Assign an admin_set based on what is returned by #determine_admin_set
  # @return [AdminSet]
  def assign_admin_set(school = self.school, department = self.department)
    as = AdminSet.where(title_sim: determine_admin_set(school, department)).first
    self.admin_set = as
    as
  end

  property :legacy_id, predicate: "http://id.loc.gov/vocabulary/identifiers/local"

  # Get all attached file sets that are "primary"
  def primary_file_fs
    members.select(&:primary?)
  end

  # Get all attached file sets that are not "primary"
  def supplemental_files_fs
    members.reject(&:primary?)
  end

  property :abstract, predicate: "http://purl.org/dc/terms/abstract" do |index|
    index.as :stored_searchable
  end

  property :table_of_contents, predicate: "http://purl.org/dc/terms/tableOfContents" do |index|
    index.as :stored_searchable
  end

  property :creator, predicate: "http://id.loc.gov/vocabulary/relators/aut" do |index|
    index.as :stored_searchable, :facetable
  end

  property :graduation_year, predicate: "http://purl.org/dc/terms/issued", multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :keyword, predicate: "http://schema.org/keywords" do |index|
    index.as :stored_searchable, :facetable
  end

  property :email, predicate: "http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#officeEmailAddress" do |index|
    index.as :displayable
  end

  property :post_graduation_email, predicate: "http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#privateEmailAddress" do |index|
    index.as :displayable
  end

  property :graduation_date, predicate: "http://purl.org/dc/terms/issued" do |index|
    index.as :stored_searchable, :facetable
  end

  # Boolean
  property :hidden, predicate: "http://emory.edu/local/hidden", multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  # booleans, placeholder predicates --
  property :no_supplemental_files, predicate: "http://emory.edu/local/no_supplemental_files", multiple: false

  property :files_embargoed, predicate: "http://purl.org/spar/pso/embargoed#files", multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :abstract_embargoed, predicate: "http://purl.org/spar/pso/embargoed#abstract", multiple: false do |index|
    index.as :stored_searchable
  end

  property :toc_embargoed, predicate: "http://purl.org/spar/pso/embargoed#toc", multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :embargo_length, predicate: "http://purl.org/spar/fabio/hasEmbargoDuration", multiple: false do |index|
    index.as :displayable
  end

  # should always be Emory University (http://id.loc.gov/vocabulary/organizations/geu)
  property :degree_granting_institution, predicate: "http://id.loc.gov/vocabulary/relators/dgg", multiple: false

  property :department, predicate: "http://vivoweb.org/ontology/core#AcademicDepartment" do |index|
    index.as :stored_searchable, :facetable
  end

  property :school, predicate: "http://vivoweb.org/ontology/core#School" do |index|
    index.as :stored_searchable, :facetable
  end

  property :subfield, predicate: "http://mappings.dbpedia.org/server/ontology/classes/AcademicSubject" do |index|
    index.as :stored_searchable, :facetable
  end

  property :degree, predicate: "http://vivoweb.org/ontology/core#AcademicDegree" do |index|
    index.as :stored_searchable, :facetable
  end

  property :degree_awarded, predicate: "http://dublincore.org/documents/dcmi-terms/#terms-dateAccepted", multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :partnering_agency, predicate: "http://id.loc.gov/vocabulary/relators/ctb" do |index|
    index.as :stored_searchable
  end

  property :submitting_type, predicate: "http://www.europeana.eu/schemas/edm/hasType" do |index|
    index.as :stored_searchable, :facetable
  end

  property :research_field, predicate: ::RDF::Vocab::DC11.subject do |index|
    index.as :stored_searchable, :facetable
  end

  property :research_field_id, predicate: 'https://schema.org/category'

  property :committee_chair, predicate: "http://id.loc.gov/vocabulary/relators/ths", class_name: "CommitteeMember"

  property :committee_chair_name, predicate: "http://example.com/committee_chair_name" do |index|
    index.as :stored_searchable, :facetable
  end

  property :committee_members, predicate: "http://id.loc.gov/vocabulary/relators/rev", class_name: "CommitteeMember"

  property :committee_members_names, predicate: "http://example.com/committee_members_names" do |index|
    index.as :stored_searchable, :facetable
  end

  # About My Etd Questionaire questions
  property :copyright_question_one, predicate: "http://www.w3.org/2004/02/skos/core#note_permissions", multiple: false

  property :copyright_question_two, predicate: "http://www.w3.org/2004/02/skos/core#note_copyrights", multiple: false

  property :copyright_question_three, predicate: "http://www.w3.org/2004/02/skos/core#note_patents", multiple: false

  # accepts_nested_attributes_for can not be called until all
  # the properties are declared because it calls resource_class,
  # which finalizes the propery declarations.
  # See https://github.com/projecthydra/active_fedora/issues/847
  accepts_nested_attributes_for :committee_members,
    allow_destroy: true,
    reject_if: proc { |attrs|
      ['name', 'affiliation', 'netid'].all? do |key|
        Array(attrs[key]).all?(&:blank?)
      end
    }

  accepts_nested_attributes_for :committee_chair,
    allow_destroy: true,
    reject_if: proc { |attrs|
      ['name', 'affiliation', 'netid'].all? do |key|
        Array(attrs[key]).all?(&:blank?)
      end
    }
end
