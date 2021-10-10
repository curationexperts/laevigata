module Hyrax::UploadsControllerBehavior
  extend ActiveSupport::Concern

  included do
    load_and_authorize_resource class: Hyrax::UploadedFile
  end

  # Assumption: We only handle 1 file at a time
  def create
    @upload.attributes = upload_attributes
    @upload.save!
  end

  def upload_attributes
    upload_attributes = {}
    upload_attributes[:user] = current_user
    if params[:primary_files] && params[:primary_files].first
      upload_attributes[:pcdm_use] = "primary"
      upload_attributes[:file] = params[:primary_files].first
    elsif params[:supplemental_files] && params[:supplemental_files].first
      upload_attributes[:pcdm_use] = "supplementary"
      upload_attributes[:file] = params[:supplemental_files].first
    end
    upload_attributes
  end

  def destroy
    @upload.destroy
    head :no_content
  end
end
