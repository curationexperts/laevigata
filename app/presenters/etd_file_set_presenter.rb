class EtdFileSetPresenter < Hyrax::FileSetPresenter
  delegate :pcdm_use,
           :description,
           to: :solr_document

  def primary?
    pcdm_use == "primary"
  end

  def permission_badge
    ""
  end

  def link_name
    first_title
  end
end
