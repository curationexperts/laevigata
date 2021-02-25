# frozen_string_literal: true
module Schemas
  class EmoryEtdSchema < ActiveTriples::Schema
    property :legacy_id,             predicate: "http://id.loc.gov/vocabulary/identifiers/local"
    property :abstract,              predicate: "http://purl.org/dc/terms/abstract"
    property :table_of_contents,     predicate: "http://purl.org/dc/terms/tableOfContents"
    property :creator,               predicate: "http://id.loc.gov/vocabulary/relators/aut"
    property :keyword,               predicate: "http://schema.org/keywords"
    property :graduation_date,       predicate: "http://purl.org/dc/terms/issued"
  end
end
