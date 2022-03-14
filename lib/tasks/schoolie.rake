# frozen_string_literal: true

require "json"
require 'nokogiri'
namespace :schoolie do
  task sitemap: :environment do
    date_field = 'system_modified_dtsi'
    result = ActiveFedora::SolrService.query("has_model_ssim:Etd",
                                             fq: "workflow_state_name_ssim:published",
                                             fl: "id,#{date_field}",
                                             sort: "degree_awarded_dtsi,system_create_dtsi ASC",
                                             rows: 20_000)
    ids = result.map do |x|
      ["https://etd.library.emory.edu/concern/etds/#{x['id']}", x[date_field].to_s]
    end
    builder = Nokogiri::XML::Builder.new do |sitemap|
      sitemap.urlset("xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance",
                 xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9",
                 "xsi:schemaLocation": "http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd") {
                   ids.each { |url, date|
                     sitemap.url {
                       sitemap.loc url
                       sitemap.lastmod date
                     }
                   }
                 }
    end
    File.open(Rails.root.join("public", "sitemap.xml"), "w") { |f| f.write(builder.to_xml) }
  end
end
