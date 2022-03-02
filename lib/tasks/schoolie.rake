# frozen_string_literal: true

require "json"
namespace :schoolie do
  task sitemap: :environment do
    ids = JSON.parse(`curl -s 'http://127.0.0.1:8983/solr/laevigata/select?fq=workflow_state_name_ssim:(published%20OR%20approved)&fl=id&rows=15000'`)["response"]["docs"].map do |x| # rubocop:disable Layout/LineLength
      "http://etd.library.emory.edu/concern/etds/#{x['id']}"
    end
    File.open(Rails.root.join("public", "sitemap.txt"), "w") { |f| ids.each { |x| f.puts x } }
  end
end
