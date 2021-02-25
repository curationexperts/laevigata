# frozen_string_literal: true
module Schemas
  class EmoryEtdSchema < ActiveTriples::Schema
    property :legacy_id,             predicate: "http://id.loc.gov/vocabulary/identifiers/local"
    property :abstract,              predicate: "http://purl.org/dc/terms/abstract"
    property :table_of_contents,     predicate: "http://purl.org/dc/terms/tableOfContents"
    property :creator,               predicate: "http://id.loc.gov/vocabulary/relators/aut"
    # property :graduation_year,       predicate: "http://purl.org/dc/terms/issued", multiple: false
    property :keyword,               predicate: "http://schema.org/keywords"
    # property :email,                 predicate: "http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#officeEmailAddress"
    # property :post_graduation_email, predicate: "http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#privateEmailAddress"
    property :graduation_date,       predicate: "http://purl.org/dc/terms/issued"
    # property :hidden,                predicate: "http://emory.edu/local/hidden", multiple: false
    # property :files_embargoed,       predicate: "http://purl.org/spar/pso/embargoed#files", multiple: false
    # property :abstract_embargoed,    predicate: "http://purl.org/spar/pso/embargoed#abstract", multiple: false
    # property :toc_embargoed,         predicate: "http://purl.org/spar/pso/embargoed#toc", multiple: false
    # property :embargo_length,        predicate: "http://purl.org/spar/fabio/hasEmbargoDuration", multiple: false
  end
end
