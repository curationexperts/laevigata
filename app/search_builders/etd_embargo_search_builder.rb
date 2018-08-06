# frozen_string_literal: true
class EtdEmbargoSearchBuilder < Hyrax::EmbargoSearchBuilder
  self.default_processor_chain =
    [:with_pagination, :with_sorting, :only_active_embargoes,
     :only_etd_embargoes]

  def only_etd_embargoes(params)
    params[:fq] += ' has_model_ssim:Etd'
  end
end
