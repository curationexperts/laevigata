class EtdFileSetPresenter < Hyrax::FileSetPresenter
  delegate :pcdm_use,
           :description,
           to: :solr_document

  def primary?
    solr_document.fetch("pcdm_use_tesim", []).include?("primary")
  end

  def supplementary?
    !primary?
  end

  def permission_badge
    ""
  end

  def link_name
    first_title
  end
end
