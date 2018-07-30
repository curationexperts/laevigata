class InProgressEtdsController < ApplicationController
  def new
    authorize! :create, InProgressEtd

    @in_progress_etd = if params[:etd_id]
                         InProgressEtd.find_or_create_by(etd_id: params[:etd_id])
                       else
                         InProgressEtd.find_or_create_by(user_ppid: current_user.ppid)
                       end

    # Now that the record has been created, render the form so student can edit it:
    redirect_to action: :edit, id: @in_progress_etd.id
  end

  # Note: There is no 'create' action because the 'new' action does 'find or create'.

  def edit
    @in_progress_etd = InProgressEtd.find(params[:id])
    authorize! :update, @in_progress_etd
    @in_progress_etd.refresh_from_etd!
    @data = @in_progress_etd.data
  end

  # The Vue.js form uses this action to update the record.
  def update
    @in_progress_etd = InProgressEtd.find(params[:id])
    authorize! :update, @in_progress_etd
    @in_progress_etd.data = prepare_etd_data.to_json

    if @in_progress_etd.save
      @data = @in_progress_etd.data
      render json: { in_progress_etd: @data, lastCompletedStep: current_step(@data), tab_name: tab_name }, status: 200
    else
      render json: { errors: @in_progress_etd.errors.messages }, status: 422
    end
  end

  def show
    @in_progress_etd = InProgressEtd.find(params[:id])
    @etd = InProgressEtd.find(params[:id]).data
    @uploaded_files = ["1"]

    render json: { in_progress_etd: @etd, uploaded_files: @uploaded_files }, status: 200
  end

  private

    def current_step(data)
      saved_data = JSON.parse(data)
      saved_data['currentStep']
    end

    def tab_name
      etd = request.parameters.fetch(:etd)
      etd.fetch(:currentTab, "About Me")
    end

    def prepare_etd_data
      # TODO: strong params
      new_data = request.parameters.fetch(:etd, {})
      # Add temporarily hard-coded data into the new data
      # TODO: Replace the hard-coded data with real data from the form
      add_supplemental_file_data(new_data)
      # uploaded_files = Hyrax::UploadedFile.id
      # add_uploaded_file_data(new_data)
      add_agreement_data(new_data)

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
