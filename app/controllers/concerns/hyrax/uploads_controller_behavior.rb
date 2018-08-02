module Hyrax::UploadsControllerBehavior
  extend ActiveSupport::Concern

  included do
    load_and_authorize_resource class: Hyrax::UploadedFile
  end

  # Assumption: We only handle 1 file at a time
  def create
    @upload.attributes = upload_attributes
    hard_code_file
    @upload.save!
    queue_box_download
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

  # Student wants to upload a remote file from Box
  def box_upload?
    params['remote_url'].present?
  end

  # If the student is uploading a file from Box, we
  # don't have the file available yet, so we need to
  # temporarily hard-code @upload.file to an object
  # with a filename (because the hyrax view assumes it
  # will be there).
  def hard_code_file
    return unless Rails.application.config_for(:new_ui).fetch('enabled', false)
    return unless box_upload?

    filename = params['filename'] || "temporary_filename.pdf"
    fuf = ::FakeUploadedFile.new(filename)
    fuf.original_filename = filename
    @upload.file = fuf
    fuf.close
  end

  # Queue background job to fetch the file from Box
  def queue_box_download
    return unless Rails.application.config_for(:new_ui).fetch('enabled', false)
    return unless box_upload?

    ::FetchRemoteFileJob.perform_later(@upload.id, params['remote_url'])
  end

  def destroy
    @upload.destroy
    head :no_content
  end
end
