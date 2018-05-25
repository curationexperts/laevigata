class FileSetUseIndexer < Hyrax::FileSetIndexer
  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['pcdm_use_tesim'] = object.pcdm_use
    end
  end
end
