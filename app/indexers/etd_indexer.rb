class EtdIndexer < Hyrax::WorkIndexer
  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['committee_names_sim'] = committee_names
    end
  end

  def committee_names
    object.committee_members.map(&:name_and_affiliation).flatten +
      object.committee_chair.map(&:name_and_affiliation).flatten
  end

  def rdf_service
    IndexingService
  end

  class IndexingService < Hyrax::BasicMetadataIndexer
    self.stored_fields +=
      [:abstract, :email, :post_graduation_email, :table_of_contents, :hidden?]

    self.stored_and_facetable_fields +=
      [:creator, :graduation_date, :files_embargoed,
       :abstract_embargoed, :toc_embargoed]
  end
end
