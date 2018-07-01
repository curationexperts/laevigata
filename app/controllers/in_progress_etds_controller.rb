class InProgressEtdsController < ApplicationController
  def new
    @in_progress_etd = InProgressEtd.find_or_create_by(user_ppid: current_user.id)
  end

  def create
    @in_progress_etd = InProgressEtd.new
    @in_progress_etd.data = prepare_etd_data.to_json
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
    @etd = InProgressEtd.find(params[:id]).data
    @uploaded_files = ["1"] # @etd['uploaded_files']
  end

  private

    def prepare_etd_data
      etd = request.parameters.fetch(:etd)
      prepare_committee_data(etd)
      add_supplemental_file_data(etd)
      # uploaded_files = Hyrax::UploadedFile.id
      # add_uploaded_file_data(etd)
      add_agreement_data(etd)
      add_embargo_data(etd)
      add_school_and_department(etd)
      etd
    end

    def prepare_committee_data(etd)
      # use real names; check what type of nested_id is needed.
      etd["committee_chair_attributes"] = { "0" => {
        "affiliation_type" => "Emory Committee Chair", "name" => ["Curie, Marie"],
        "id" => "#nested_g70334968021140"
      }, "1" => { "affiliation_type" =>
        "Emory Committee Chair", "name" => [""] } }

      etd["committee_members_attributes"] = { "0" =>
      { "affiliation_type" => "Non-Emory Committee Member", "affiliation" => ["NASA"],
        "name" => ["Maher, Valerie"], "id" => "#nested_g70334919944200" } }
    end

    # TODO: Get each of these from the form

    def add_supplemental_file_data(etd)
      etd["no_supplemental_files"] = "0"
    end

    def add_uploaded_file_data(etd)
      etd["uploaded_files"] = "1"
    end

    def add_agreement_data(etd)
      etd["agreement"] = "1"
    end

    def add_embargo_data(etd)
      etd["no_embargoes"] = "1"
    end

    def add_school_and_department(etd)
      etd["school"] = "Emory College"
      etd["department"] = "Anthropology"
    end

    # TODO: confirm whether this is not needed
    def in_progress_etd_params
      terms = TermService.new(etd_terms: Hyrax::EtdForm.terms).filtered_terms
      terms << "committee_chair_attributes"
      terms << "committee_members_attributes"
      terms << "uploaded_files"
      terms << "no_embargoes"
      terms << "agreement"
      terms << "no_supplemental_files"
      params.permit(terms)
    end
end
