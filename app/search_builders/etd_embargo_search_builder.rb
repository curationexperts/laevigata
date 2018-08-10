# frozen_string_literal: true
##
# A custom search builder limiting Embargo search to embargoes on `Etd` objects.
#
# @see Blacklight::SearchBuilder
class EtdEmbargoSearchBuilder < Hyrax::EmbargoSearchBuilder
  self.default_processor_chain =
    [:with_pagination, :with_sorting, :only_etd_embargoes]

  def only_etd_embargoes(params)
    params[:fq] = '+embargo_release_date_dtsi:* +has_model_ssim:Etd'
  end
end
