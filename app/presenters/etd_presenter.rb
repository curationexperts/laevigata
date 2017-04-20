class EtdPresenter < Hyrax::WorkShowPresenter
  delegate :degree, to: :solr_document
  delegate :department, to: :solr_document
  delegate :school, to: :solr_document

  delegate :degree, to: :solr_document
end
