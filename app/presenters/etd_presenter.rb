class EtdPresenter < Hyrax::WorkShowPresenter
  delegate :degree, :department, :school, to: :solr_document
end
