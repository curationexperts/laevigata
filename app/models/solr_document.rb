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

  def table_of_contents
    self[Solrizer.solr_name('table_of_contents')]
  end

  def committee_chair_name
    self[Solrizer.solr_name('committee_chair_name')]
  end

  def committee_members_names
    self[Solrizer.solr_name('committee_members_names')]
  end

  def degree
    self[Solrizer.solr_name('degree')]
  end

  def department
    self[Solrizer.solr_name('department')]
  end

  def graduation_year
    self[Solrizer.solr_name('graduation_year')]
  end

  def school
    self[Solrizer.solr_name('school')]
  end

  def subfield
    self[Solrizer.solr_name('subfield')]
  end

  def supplementary
    self[Solrizer.solr_name('supplementary')]
  end

  def partnering_agency
    self[Solrizer.solr_name('partnering_agency')]
  end

  def primary
    self[Solrizer.solr_name('primary')]
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
end
