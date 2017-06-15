# frozen_string_literal: true
require 'active_triples'

class CommitteeMember < ActiveTriples::Resource
  include ActiveTriples::RDFSource
  configure type: RDF::Vocab::FOAF.Person

  property :name, predicate: RDF::Vocab::FOAF.name
  property :affiliation, predicate: "http://vivoweb.org/ontology/core#School"
  property :netid, predicate: "http://open.vocab.org/terms/accountIdentifier"

  def to_s
    "#{name.first}, #{affiliation.first} (#{netid.first})"
  end
end
