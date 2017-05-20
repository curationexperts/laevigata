class EtdPresenter < Hyrax::WorkShowPresenter
  delegate :degree, :department, :school, :partnering_agency, to: :solr_document
end
