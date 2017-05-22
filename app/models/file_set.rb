# Generated by hyrax:models:install
class FileSet < ActiveFedora::Base
  include ::Hyrax::FileSetBehavior

  PRIMARY = 'http://pcdm.org/use#primary'.freeze
  SUPPLEMENTARY = 'http://pcdm.org/use#supplementary'.freeze

  property :primary, predicate: 'http://pcdm.org/use', multiple: false do |index|
    index.as :facetable
  end

  property :supplementary, predicate: 'http://pcdm.org/use#supplementary' do |index|
    index.as :facetable
  end

  validate :primary_should_match_vocabulary

  def primary_should_match_vocabulary
    self.primary = SUPPLEMENTARY unless primary == PRIMARY
  end

  def primary?
    primary == PRIMARY
  end

  def supplementary?
    !primary?
  end
end
