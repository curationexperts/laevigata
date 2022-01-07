namespace :hax do
  task :reindex => :environment do
    require 'active_fedora'
    require 'active_fedora/solr_service'
    require 'reindexotron'
    z = Reindexotron.fetch_roots(ActiveFedora.fedora.base_uri)

    Parallel.each(z.map{|x| x.object.to_s}, in_processes: 8 ) do |n|
      Reindexotron.walk(n, []).each do |uri|
        k = ActiveFedora::Base.find(ActiveFedora::Base.uri_to_id(uri)).to_solr
        begin
          puts "Indexing #{uri} in worker #{Parallel.worker_number}"
          ActiveFedora::SolrService.add(k, softCommit: true)
        rescue
          puts "error on #{k}: #{$!.message}"
        end
      end
    end
    ActiveFedora::SolrService.commit
  end
end

