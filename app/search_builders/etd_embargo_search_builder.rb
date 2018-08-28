# frozen_string_literal: true
##
# A custom search builder limiting Embargo search to embargoes on `Etd` objects.
#
# @see Blacklight::SearchBuilder
class EtdEmbargoSearchBuilder < Hyrax::EmbargoSearchBuilder
  self.default_processor_chain =
    [:many_results, :with_sorting, :only_etd_embargoes]

  def only_etd_embargoes(params)
    params[:fq] = '+embargo_release_date_dtsi:* +has_model_ssim:Etd'
  end

  private

    ##
    # Show more results than repository scale
    #
    # This is pending a more proper pagination implementation as called for at
    # https://github.com/samvera/hyrax/blob/5a9d1be16ee1a9150646384471992b03aab527a5/app/search_builders/hyrax/embargo_search_builder.rb#L6
    def many_results(params)
      params[:rows] = 50_000
    end
end
