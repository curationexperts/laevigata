class EtdPresenter < Hyrax::WorkShowPresenter
  delegate :abstract,
           :committee_chair_name,
           :committee_members_names,
           :degree,
           :department,
           :school,
           :subfield,
           :partnering_agency,
           :research_field,
           :submitting_type,
           :table_of_contents,
           to: :solr_document
end
