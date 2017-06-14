class EtdPresenter < Hyrax::WorkShowPresenter
  delegate :degree, :department, :school, :subfield, :partnering_agency, :submitting_type, :research_field, to: :solr_document
end
