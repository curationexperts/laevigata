# frozen_string_literal: true

class TermService
  attr_reader :etd_terms

  FILTERED_TERMS = [:identifier, :representative_id, :thumbnail_id, :rendering_ids,
                    :ordered_member_ids, :in_works_ids, :member_of_collection_ids,
                    :admin_set_ids, :based_near, :source, :related_url].freeze

  def initialize(etd_terms: [])
    @etd_terms = etd_terms
  end

  def terms
    @etd_terms
  end

  def rejected_terms
    FILTERED_TERMS
  end

  def filtered_terms
    @etd_terms.reject { |term| rejected_terms.include?(term) }
  end
end
