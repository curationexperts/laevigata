# frozen_string_literal: true
module Schemas
  # include these properties in their own schema in order to redefine the mappings
  # included via Hyrax::BasicMetadata
  class EmoryEtdSchema < ActiveTriples::Schema
    property :keyword,               predicate: "http://schema.org/keywords"
    property :creator,               predicate: "http://id.loc.gov/vocabulary/relators/aut"
  end
end
