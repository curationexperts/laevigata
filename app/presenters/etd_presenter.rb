class EtdPresenter < Hyrax::WorkShowPresenter
  delegate :abstract, :degree, :department, :school, :subfield, :partnering_agency, :submitting_type, :research_field, :committee_chair_name, :committee_members_names, to: :solr_document
end
