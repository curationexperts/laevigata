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
      params["in_progress_etd"].each do |field|
        params["in_progress_etd"][field.to_s] = Array.wrap(params["in_progress_etd"][field.to_s])
      end
    end

    def in_progress_etd_params
      params.permit(Hyrax::EtdForm.terms)
    end
end
