class EtdPresenter < Hyrax::WorkShowPresenter
  delegate :abstract,
           :committee_chair_name,
           :committee_members_names,
           :degree,
           :department,
           :graduation_year,
           :school,
           :subfield,
           :partnering_agency,
           :research_field,
           :rights_statement,
           :submitting_type,
           :table_of_contents,
           to: :solr_document

  # Given an ARK in the identifier field, return an Emory permanent_url
  def permanent_url
    return nil unless identifier && identifier.first && identifier.first.match(/^ark/)
    "http://pid.emory.edu/#{identifier.first}"
  end
end
