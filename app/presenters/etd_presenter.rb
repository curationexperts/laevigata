class EtdPresenter < Hyrax::WorkShowPresenter
  delegate :degree, :department, :school, :partnering_agency, :submitting_type, to: :solr_document
end
