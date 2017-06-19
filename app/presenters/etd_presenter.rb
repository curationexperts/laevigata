class EtdPresenter < Hyrax::WorkShowPresenter
  delegate :degree, :department, :school, :subfield, :partnering_agency, :submitting_type, :research_field, :committee_chair_name, :committee_members_names, to: :solr_document

  # Given an ARK in the identifier field, return an Emory permanent_url
  def permanent_url
    return nil unless identifier && identifier.first && identifier.first.match(/^ark/)
    "http://pid.emory.edu/#{identifier.first}"
  end
end
