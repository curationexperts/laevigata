namespace :index do
  task reindex: :environment do
    require 'active_fedora'
    require 'active_fedora/solr_service'
    require 'reindexotron'

    z = Reindexotron.fetch_roots(ActiveFedora.fedora.base_uri)
    z = z.map{|x| x.object}.select{|x| x.is_a? RDF::URI}.map(&:to_s).reject{|x| x==ActiveFedora.fedora.base_uri}

    Parallel.each(z, processors: 4) do |r|
      Reindexotron.walk(r) do |uri|
        begin
          k = ActiveFedora::Base.find(ActiveFedora::Base.uri_to_id(uri)).to_solr
          ActiveFedora::SolrService.add(k, softCommit: true)
        rescue
          puts "error on #{k}: #{$ERROR_INFO.message}"
        end
      end
    end
  end
  ActiveFedora::SolrService.commit
end
