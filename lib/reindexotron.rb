class Reindexotron 
  class << self
    def fetch_roots(uri)
      resource = Ldp::Resource::RdfSource.new(ActiveFedora.fedora.build_ntriples_connection, uri)
      resource.graph.query(predicate: ::RDF::Vocab::LDP.contains)
    end

    def walk(uri, accum, &block)
      resource = Ldp::Resource::RdfSource.new(ActiveFedora.fedora.build_ntriples_connection, uri)
      return accum unless resource.head.rdf_source?
      accum << uri
      resource.graph.query(predicate: ::RDF::Vocab::LDP.contains).map{|x| x.object.to_s}.each do |uri|
        walk(uri, accum)
      end
      accum
    end
  end
end

