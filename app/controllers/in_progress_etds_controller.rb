class InProgressEtdsController < ApplicationController
  def new
    @in_progress_etd = InProgressEtd.find_or_create_by(user_ppid: current_user.id)
    @data = @in_progress_etd.data unless @in_progress_etd.data.nil?
  end

  # TODO: this is effectively always an update. Should we just use the update action instead?
  # TODO: this needs to be authorized
  def create
    @in_progress_etd = InProgressEtd.find_by(user_ppid: current_user.id)
    @in_progress_etd.data = prepare_etd_data.to_json

    if @in_progress_etd.save
      # TODO: we'll want all the json data sent back
      render json: { in_progress_etd: @in_progress_etd, lastCompletedStep: current_step, tab_name: tab_name }, status: 200
    else
      render json: { errors: @in_progress_etd.errors.messages }, status: 422
    end
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

    # @uploaded_files = ["1"] # JSON.parse(@in_progress_etd.data)['uploaded_files']
    # @uploaded_files = []
  end

  private

    def current_step
      etd = request.parameters.fetch(:etd)
      etd.fetch(:currentStep, 0)
    end

    def tab_name
      etd = request.parameters.fetch(:etd)
      etd.fetch(:currentTab, "About Me")
    end

    def prepare_etd_data
      new_data = request.parameters.fetch(:etd, {})

      # Add temporarily hard-coded data into the new data
      # TODO: Replace the hard-coded data with real data from the form
      add_supplemental_file_data(new_data)
      # uploaded_files = Hyrax::UploadedFile.id
      # add_uploaded_file_data(new_data)
      add_agreement_data(new_data)
      add_embargo_data(new_data)
      add_school_department_subfield(new_data)

      # Add the new data to the existing persisted data
      @in_progress_etd.add_data(new_data)
    end

    # TODO: Get each of these from the form

    def add_supplemental_file_data(etd)
      etd["no_supplemental_files"] = "0"
    end

    def add_uploaded_file_data(etd)
      etd["uploaded_files"] = "3"
    end

    def add_agreement_data(etd)
      etd["agreement"] = "1"
    end

    def add_embargo_data(etd)
      etd["no_embargoes"] = "1"
    end

    def add_school_department_subfield(etd)
      etd["school"] = "Emory College"
      etd["department"] = "Anthropology"
      etd["subfield"] = "Epidemiology"
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
