# Generated by hyrax:models:install
class FileSet < ActiveFedora::Base
  include ::Hyrax::FileSetBehavior

  ORIGINAL      = 'original'.freeze
  PREMIS        = 'premis'.freeze
  PRIMARY       = 'primary'.freeze
  SUPPLEMENTARY = 'supplementary'.freeze
  SUPPLEMENTAL  = 'supplementary'.freeze

  property :embargo_length, predicate: "http://purl.org/spar/fabio/hasEmbargoDuration", multiple: false do |index|
    index.as :displayable
  end

  property :pcdm_use, predicate: 'http://pcdm.org/use', multiple: false do |index|
    index.as :facetable
  end

  property :file_type, predicate: 'http://purl.org/dc/elements/1.1/format', multiple: false do |index|
    index.as :facetable
  end

  def original?
    pcdm_use == ORIGINAL
  end

  def premis?
    pcdm_use == PREMIS
  end

  def primary?
    pcdm_use == PRIMARY
  end

  def supplementary?
    !primary? && !premis? && !original?
  end
end
