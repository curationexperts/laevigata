# frozen_string_literal: true

require "json"
require 'nokogiri'
namespace :schoolie do
  task sitemap: :environment do
    ids = JSON.parse(`curl -s '#{ENV.fetch("SOLR_URL")}/select?fq=workflow_state_name_ssim:(published%20OR%20approved)&fl=id,degree_awarded_dtsi&rows=15000&sort=degree_awarded_dtsi%20ASC'`)["response"]["docs"].map do |x| # rubocop:disable Layout/LineLength
      ["https://etd.library.emory.edu/concern/etds/#{x['id']}", (x['degree_awarded_dtsi']).to_s]
    end
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.urlset("xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance",
                 xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9",
                 "xsi:schemaLocation": "http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd") {
                   ids.each { |u, d|
                     xml.url {
                       xml.loc u
                       xml.lastmod d if d.present?
                     }
                   }
                 }
    end
    File.open(Rails.root.join("public", "sitemap.xml"), "w") { |f| f.write(builder.to_xml) }
  end
end
