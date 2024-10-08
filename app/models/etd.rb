require 'workflow_setup'

class Etd < ActiveFedora::Base
  include ::ProquestBehaviors
  include ::Hyrax::WorkBehavior

  EMBARGO_TRUTHINESS_VALUES = [true, 'true', 'TRUE'].freeze

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
  delegate :embargo_type, to: :visibility_translator

  # Get all attached file sets that are "primary"
  def primary_file_fs
    members.select(&:primary?)
  end

  # Get primary pdf file
  def primary_pdf_file
    members.select(&:primary?).first.files.select { |a| a.mime_type == "application/pdf" }.first
  end

  ##
  # Get all attached file sets that are "supplementary"
  def supplemental_files_fs
    members.select(&:supplementary?)
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

  # Boolean
  property :hidden, predicate: "http://emory.edu/local/hidden", multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  # booleans, placeholder predicates --
  property :files_embargoed, predicate: "http://purl.org/spar/pso/embargoed#files", multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  def files_embargoed=(value)
    Rails.logger.warn("Setting #{__method__} to #{value} is deprecated. Casting to `true`.") if
      ['true', 'TRUE'].include?(value)

    super(EMBARGO_TRUTHINESS_VALUES.include?(value))
  end

  def files_embargoed
    EMBARGO_TRUTHINESS_VALUES.include?(super)
  end

  property :abstract_embargoed, predicate: "http://purl.org/spar/pso/embargoed#abstract", multiple: false do |index|
    index.as :stored_searchable
  end

  def abstract_embargoed=(value)
    Rails.logger.warn("Setting #{__method__} to #{value} is deprecated. Casting to `true`.") if
      ['true', 'TRUE'].include?(value)

    super(EMBARGO_TRUTHINESS_VALUES.include?(value))
  end

  def abstract_embargoed
    EMBARGO_TRUTHINESS_VALUES.include?(super)
  end

  property :toc_embargoed, predicate: "http://purl.org/spar/pso/embargoed#toc", multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  def toc_embargoed=(value)
    Rails.logger.warn("Setting #{__method__} to #{value} is deprecated. Casting to `true`.") if
      ['true', 'TRUE'].include?(value)

    super(EMBARGO_TRUTHINESS_VALUES.include?(value))
  end

  def toc_embargoed
    EMBARGO_TRUTHINESS_VALUES.include?(super)
  end

  property :embargo_length, predicate: "http://purl.org/spar/fabio/hasEmbargoDuration", multiple: false do |index|
    index.as :stored_sortable
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

  # [String] representing the semester and year the student graduates; legacy records only have a year value
  property :graduation_date, predicate: "http://purl.org/dc/terms/issued", multiple: false do |index|
    index.as :stored_sortable, :facetable
  end

  # [Time] stores the day recorded by the Registrar on which a degree was awarded - typically truncates or ignores time portion of the value
  property :degree_awarded, predicate: "http://dublincore.org/documents/dcmi-terms/#terms-dateAccepted", multiple: false do |index|
    index.as :stored_sortable
  end

  # override degree_awarded setter to always cast the value to a Date type object
  #   convert all values to UTC for compatibility with Solr - see https://solr.apache.org/guide/8_11/working-with-dates.html
  def degree_awarded=(value)
    case value
    when Time
      super(value.utc)
    when Date
      super(value.to_time.utc)
    when String
      Rails.logger.warn("Assigning #{__method__} to a string is deprecated. Casting to a Time class value.")
      super(Date.parse(value).at_midnight.utc)
    when NilClass
      super(nil)
    else
      raise ArgumentError, "You attempted to set the property 'degree_awarded_date' for ETD id:#{id} to an unsupported value of type '#{value.class}'"
    end
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

  # What date (if any) was this ETD submitted to ProQuest?
  property :proquest_submission_date, predicate: "http://example.com/proquest_submission_date" do |index|
    index.as :stored_searchable
  end

  property :abstract,              predicate: ::RDF::Vocab::DC.abstract
  property :keyword,               predicate: ::RDF::Vocab::SCHEMA.keywords
  property :rights_statement,      predicate: ::RDF::Vocab::EDM.rights
  property :language,              predicate: ::RDF::Vocab::DC11.language
  property :table_of_contents,     predicate: "http://purl.org/dc/terms/tableOfContents"
  property :creator,               predicate: "http://id.loc.gov/vocabulary/relators/aut"
  property :legacy_id,             predicate: "http://id.loc.gov/vocabulary/identifiers/local"

  # The following properties would be included via
  # # include ::Hyrax::BasicMetadata
  # These properties are not used by the ETD application;
  # however, the uncommented properties are required in order
  # for solr document generation to succeed because they are
  # currently hard-coded into Hyrax in
  # https://github.com/samvera/hyrax/blob/v2.9.6/app/models/concerns/hyrax/solr_document/metadata.rb
  #
  # property :alternative_title, predicate: ::RDF::Vocab::DC.alternative
  property :date_created, predicate: ::RDF::Vocab::DC.created
  # property :label, predicate: ActiveFedora::RDF::Fcrepo::Model.downloadFilename, multiple: false
  # property :relative_path, predicate: ::RDF::URI.new('http://scholarsphere.psu.edu/ns#relativePath'), multiple: false
  property :import_url, predicate: ::RDF::URI.new('http://scholarsphere.psu.edu/ns#importUrl'), multiple: false
  property :contributor, predicate: ::RDF::Vocab::DC11.contributor
  property :description, predicate: ::RDF::Vocab::DC11.description
  # property :access_right, predicate: ::RDF::Vocab::DC.accessRights
  # property :description, predicate: ::RDF::Vocab::DC11.description
  property :license, predicate: ::RDF::Vocab::DC.license, multiple: true
  property :publisher, predicate: ::RDF::Vocab::DC11.publisher
  property :subject, predicate: ::RDF::Vocab::DC.subject # see research_field which uses elements instead of terms namespace
  property :identifier, predicate: ::RDF::Vocab::DC.identifier
  property :based_near, predicate: ::RDF::Vocab::FOAF.based_near, class_name: Hyrax::ControlledVocabularies::Location
  property :related_url, predicate: ::RDF::RDFS.seeAlso
  property :bibliographic_citation, predicate: ::RDF::Vocab::DC.bibliographicCitation
  property :resource_type, predicate: ::RDF::Vocab::DC.type
  # property :rights_notes, predicate: ::RDF::URI.new('http://purl.org/dc/elements/1.1/rights'), multiple: true
  property :source, predicate: ::RDF::Vocab::DC.source

  # apply_schema Schemas::EmoryEtdSchema, Schemas::GeneratedResourceSchemaStrategy.new

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
    self.committee_chair_name = committee_chair.map(&:name_and_affiliation)
  end

  def index_committee_members_names
    self.committee_members_names = committee_members.map(&:name_and_affiliation)
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
    return "Default Admin Set" if migrated?
    as_name = AdminSetChooser.new.determine_admin_set(school, department)
    raise "Cannot find admin set config where school = #{school.first} and department = #{department.first}" unless as_name
    as_name
  end

  # Works that were migrated from the previous system were put into the default admin set,
  # and have been marked as published. When they are edited, they should stay in the default
  # admin set -- we should not try to assign them to a different one based on their school and
  # department.
  def migrated?
    return false unless self&.admin_set&.title&.first == "Default Admin Set"
    true
  end

  # Assign an admin_set based on what is returned by #determine_admin_set
  # @return [AdminSet]
  def assign_admin_set(school = self.school, department = self.department)
    as = AdminSet.where(title_sim: determine_admin_set(school, department)).first
    self.admin_set = as
    as
  end
end
