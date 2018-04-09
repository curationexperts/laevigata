class FileSetPresenter < Hyrax::FileSetPresenter
  delegate :pcdm_use,
           :description,
           to: :solr_document

  def primary?
    return true if solr_document["pcdm_use_tesim"] == "primary"
    false
  end

  def supplementary?
    return true if solr_document["pcdm_use_tesim"] == "supplementary"
    false
  end

  ##
  # @note we never display permission badges for `FileSet` objects, embargo
  #   status depends on the parent `Etd`
  #
  # @return [String] sanitized HTML for the permission badge
  def permission_badge
    ''
  end
end
