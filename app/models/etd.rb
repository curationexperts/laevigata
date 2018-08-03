require 'workflow_setup'

class Etd < ActiveFedora::Base
  include ::ProquestBehaviors
  include ::Hyrax::WorkBehavior

  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []

  self.indexer = EtdIndexer

  validates :title, presence: { message: 'Your work must have a title.' }
  validates :research_field, length: { maximum: 3 }

  after_initialize :set_defaults, unless: :persisted?
  before_save :set_research_field_ids, :index_committee_chair_name, :index_committee_members_names

  ##
  # @!attribute [rw] visibility_translator_class
  #   @return [VisibilityTranslatorClass]
  attr_writer :visibility_translator_class

  def visibility_translator_class
    @visibility_translator_class ||= VisibilityTranslator
  end

  ##
  # @return [VisibilityTranslator]
  def visibility_translator
    visibility_translator_class.new(obj: self)
  end

  delegate :visibility,  to: :visibility_translator
  delegate :visibility=, to: :visibility_translator

  # Get all attached file sets that are "primary"
  def primary_file_fs
    members.select(&:primary?)
  end

  # Get primary pdf file
  def primary_pdf_file
    members.select(&:primary?).first.files.select { |a| a.mime_type == "application/pdf" }.first
  end

  ##
  # @return [Enumerable<FileSet>] attached premis file(s), if any
  def premis_files_fs
    members.select(&:premis?)
  end

  ##
  # Get all attached file sets that are "supplementary"
  def supplemental_files_fs
    members.select(&:supplementary?)
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
  property :requires_permissions, predicate: "http://www.w3.org/2004/02/skos/core#note_permissions", multiple: false do |index|
    index.as :stored_searchable
  end

  property :other_copyrights, predicate: "http://www.w3.org/2004/02/skos/core#note_copyrights", multiple: false do |index|
    index.as :stored_searchable
  end

  property :patents, predicate: "http://www.w3.org/2004/02/skos/core#note_patents", multiple: false do |index|
    index.as :stored_searchable
  end

  # If this user can choose whether to submit to ProQuest or not, what was their choice?
  property :choose_proquest_submission, predicate: "http://example.com/choose_proquest_submission" do |index|
    index.as :stored_searchable
  end

  # What date (if any) was this ETD submitted to ProQuest?
  property :proquest_submission_date, predicate: "http://example.com/proquest_submission_date" do |index|
    index.as :stored_searchable
  end

  include ::Hyrax::BasicMetadata
  apply_schema Schemas::EmoryEtdSchema, Schemas::GeneratedResourceSchemaStrategy.new

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
    as_name = AdminSetChooser.new.determine_admin_set(school, department)
    raise "Cannot find admin set config where school = #{school.first} and department = #{department.first}" unless as_name
    as_name
  end

  # Assign an admin_set based on what is returned by #determine_admin_set
  # @return [AdminSet]
  def assign_admin_set(school = self.school, department = self.department)
    as = AdminSet.where(title_sim: determine_admin_set(school, department)).first
    self.admin_set = as
    as
  end
end
