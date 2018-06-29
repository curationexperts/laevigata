class InProgressEtdsController < ApplicationController
  def new
    @in_progress_etd = InProgressEtd.find_or_create_by(user_ppid: current_user.id)
  end

  def create
    @in_progress_etd = InProgressEtd.new
    @in_progress_etd.data = sanitize_params.to_json
    @in_progress_etd.save
    redirect_to @in_progress_etd
  end

  def edit
    @in_progress_etd = InProgressEtd.find(params[:id])
  end

  def update
    @in_progress_etd = InProgressEtd.find(params[:id])

    if @in_progress_etd.update(in_progress_etd_params)
      redirect_to @in_progress_etd
    else
      render 'edit'
    end
  end

  def show
    @in_progress_etd = InProgressEtd.find(params[:id])
  end

  private

    def sanitize_params
      params["etd"].delete("committee_chair")
      params["etd"].delete("committee_members")
      prepare_committee_data

      params["etd"]
    end

    def prepare_committee_data
      # use real names; check what type of id is needed.
      params["etd"]["committee_chair_attributes"] = { "0" => {
        "affiliation_type" => "Emory Committee Chair", "name" => ["Curie, Marie"],
        "id" => "#nested_g70334968021140"
      }, "1" => { "affiliation_type" =>
        "Emory Committee Chair", "name" => [""] } }

      params["etd"]["committee_members_attributes"] = { "0" =>
      { "affiliation_type" => "Non-Emory Committee Member", "affiliation" => ["NASA"],
        "name" => ["Maher, Valerie"], "id" => "#nested_g70334919944200" } }
    end

    def in_progress_etd_params
      terms = TermService.new(etd_terms: Hyrax::EtdForm.terms).filtered_terms
      terms << "committee_chair_attributes"
      terms << "committee_members_attributes"
      params.permit(terms)
    end
end
