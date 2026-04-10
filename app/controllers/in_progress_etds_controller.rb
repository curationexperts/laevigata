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
    if current_user.nil?
      redirect_to new_user_session_path
    else
      debugger
      @in_progress_etd = InProgressEtd.find(params[:id])
      authorize! :update, @in_progress_etd
      @in_progress_etd.refresh_from_etd!
      @data = @in_progress_etd.data
      @form_level = form_level
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to root_url
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

  def destroy
    @in_progress_etd = InProgressEtd.find(params[:id])
    authorize! :update, @in_progress_etd
    @in_progress_etd.destroy

    redirect_to root_url
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

      # Add the new data to the existing persisted data
      @in_progress_etd.add_data(new_data)
    end

    # Determine whether to render basic form or advanced
    # @return :basic, :advanced
    def form_level
      return :advanced if current_user_can_approve?
      :basic
    end

  def current_user_can_approve?
    return true if current_user.admin?

    # Check whether the user has approving privileges regardless of admin set,
    # because an admin set is not assigned until the user submits the InProcessEtd.
    #
    # similar to: current_ability.send(:can_review_submissions?), but only makes a single DB call for
    # current_user --> sipity_agent --> workflow_responsibilities --> workflow_role --> role(name: 'approving')
    current_user.to_sipity_agent.workflow_responsibilities.joins(workflow_role: :role)
                .where(sipity_roles: {name: Hyrax::RoleRegistry::APPROVING}).present?
  end
end
