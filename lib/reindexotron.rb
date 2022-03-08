class Reindexotron
  class << self
    def fetch_roots(uri)
      resource = Ldp::Resource::RdfSource.new(ActiveFedora.fedora.build_ntriples_connection, uri)
      resource.graph.query(predicate: ::RDF::Vocab::LDP.contains)
    end

    def walk(uri, &block)
      resource = Ldp::Resource::RdfSource.new(ActiveFedora.fedora.build_ntriples_connection, uri)
      if resource.head.rdf_source?
        resource.graph.query(predicate: ::RDF::Vocab::LDP.contains).map { |x| x.object.to_s }.each do |t|
          walk(t, &block)
        end
        yield uri
      end
    end
  end
end
