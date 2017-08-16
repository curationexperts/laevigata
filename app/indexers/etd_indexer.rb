class EtdIndexer < Hyrax::WorkIndexer
  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['committee_names_sim'] = committee_names
    end
  end

  def committee_names
    object.committee_members.map(&:name).map(&:to_a).flatten +
      object.committee_chair.map(&:name).map(&:to_a).flatten
  end
end
