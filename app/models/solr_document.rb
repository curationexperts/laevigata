# frozen_string_literal: true
class SolrDocument
  include Blacklight::Solr::Document
  include Blacklight::Gallery::OpenseadragonSolrDocument

  # Adds Hyrax behaviors to the SolrDocument.
  include Hyrax::SolrDocumentBehavior

  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  # Do content negotiation for AF models.

  use_extension(Hydra::ContentNegotiation)

  def abstract
    self[Solrizer.solr_name('abstract')]
  end

  # If this is a boolean, return the boolean value
  # If this is a string, transform it into a boolean
  # If the value is nil or can't be determined, assume it is NOT embargoed
  def abstract_embargoed
    return self['abstract_embargoed_bsi'] unless self['abstract_embargoed_bsi'].nil?
    return self['abstract_embargoed_tesim'].first.to_s == "true" if self['abstract_embargoed_tesim']
    false
  end

  # If this is a boolean, return the boolean value
  # If this is a string, transform it into a boolean
  # If the value is nil or can't be determined, assume it is NOT embargoed
  def toc_embargoed
    return self['toc_embargoed_bsi'] unless self['toc_embargoed_bsi'].nil?
    return self['toc_embargoed_tesim'].first.to_s == "true" if self['toc_embargoed_tesim']
    false
  end

  # If this is a boolean, return the boolean value
  # If this is a string, transform it into a boolean
  # If the value is nil or can't be determined, assume it is NOT embargoed
  def files_embargoed
    return self['files_embargoed_bsi'] unless self['files_embargoed_bsi'].nil?
    return self['files_embargoed_tesim'].first.to_s == "true" if self['files_embargoed_tesim']
    false
  end

  def table_of_contents
    self[Solrizer.solr_name('table_of_contents')]
  end

  def committee_chair_name
    self[Solrizer.solr_name('committee_chair_name')]
  end

  def committee_members_names
    self[Solrizer.solr_name('committee_members_names')]
  end

  def date_modified
    ActiveSupport::TimeZone['US/Eastern'].parse(fetch('date_modified_dtsi', ''))
  end

  def date_uploaded
    ActiveSupport::TimeZone['US/Eastern'].parse(fetch('date_uploaded_dtsi', ''))
  end

  def degree
    self[Solrizer.solr_name('degree')]
  end

  # @return [DateTime] - the day recorded by the Registrar that a degree wqs granted - time value it typically truncated
  # see `graduation_date` for the semester and year value used for faceting
  def degree_awarded
    self['degree_awarded_dtsi'] || self['degree_awarded_ssi'] || self['degree_awarded_dtsim']&.first || self['degree_awarded_tesim']&.first
  end

  # @return [String] - the semester and year (or just year for legacy records) of graduation - e.g. "2018", "Fall 2021"
  # see `degree_awarded` for the timestamp representing the day the degree was recorded by the Emory Registrar
  def graduation_date
    self[Solrizer.solr_name('graduation_date', :stored_sortable)] || self[Solrizer.solr_name('graduation_date', :stored_searchable)]&.first
  end

  def department
    self[Solrizer.solr_name('department')]
  end

  def description
    self[Solrizer.solr_name('description')] || []
  end

  def embargo_length
    self['embargo_length_ssi']
  end

  def hidden?
    self[Solrizer.solr_name('hidden?', type: :boolean)]
  end

  def school
    self[Solrizer.solr_name('school')]
  end

  def subfield
    self[Solrizer.solr_name('subfield')]
  end

  def partnering_agency
    self[Solrizer.solr_name('partnering_agency')]
  end

  def pcdm_use
    self[Solrizer.solr_name('pcdm_use')]
  end

  def submitting_type
    self[Solrizer.solr_name('submitting_type')]
  end

  def research_field
    self[Solrizer.solr_name('research_field')]
  end

  def rights_statement
    self[Solrizer.solr_name('rights_statement')]
  end

  def requires_permissions
    self[Solrizer.solr_name('requires_permissions')]
  end

  def other_copyrights
    self[Solrizer.solr_name('other_copyrights')]
  end

  def patents
    self[Solrizer.solr_name('patents')]
  end

  def choose_proquest_submission
    self[Solrizer.solr_name('choose_proquest_submission')]
  end

  def proquest_submission_date
    self[Solrizer.solr_name('proquest_submission_date')]
  end

  def visibility
    VisibilityTranslator
      .new(obj: self)
      .visibility
  end

  def under_embargo?
    embargo_release_date.present?
  end
end
