class FileSetPresenter < Hyrax::FileSetPresenter
  delegate :pcdm_use,
           to: :solr_document

  def primary?
    return true if solr_document["pcdm_use_tesim"] == "primary"
    false
  end

  def supplementary?
    return true if solr_document["pcdm_use_tesim"] == "supplementary"
    false
  end
end
