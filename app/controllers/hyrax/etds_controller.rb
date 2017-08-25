# Generated via
#  `rails generate hyrax:work Etd`

module Hyrax
  class EtdsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = Etd
    self.show_presenter = EtdPresenter

    helper EtdHelper

    def create
      apply_file_metadata(params) # if params["etd"]["supplemental_file_metadata"]
      # TODO: make this a case statement for each tab
      if params.fetch('partial_data', false) == "true"
        @etd_about_me = params.fetch('etd')
        render json: @etd_about_me, status: 200
      else
        super
      end
    end

    # Override from Hyrax:app/controllers/concerns/hyrax/curation_concern_controller.rb
    # Hyrax default behavior is that a user cannot see their own work if the document
    # is "suppressed", which means Hyrax::Workflow::ActivateObject has not been called.
    # In Emory's case, they do not want the object activated until the student has
    # graduated. That means we need to override the default behavior.
    def document_not_found!
      doc = ::SolrDocument.find(params[:id])
      # Render the document if the current_user == the depositor of the document
      return doc if current_user && current_user.user_key == doc["depositor_ssim"].first
      raise WorkflowAuthorizationException if doc.suppressed?
      raise CanCan::AccessDenied.new(nil, :show)
    end

    # Take supplemental file metadata and write it to the appropriate UploadedFile
    # @param [ActionController::Parameters] params
    # @return [ActionController::Parameters] params
    def apply_file_metadata(params)
      params["etd"].delete("no_supplemental_files")
      uploaded_file_ids = params["uploaded_files"]
      return if uploaded_file_ids.nil?
      uploaded_file_ids.each do |uploaded_file_id|
        uploaded_file = find_or_create_uploaded_file(uploaded_file_id)
        next if uploaded_file.pcdm_use == "primary"
        apply_metadata_to_uploaded_file(uploaded_file, params)
      end
      params["etd"].delete("supplemental_file_metadata")
      params # return the params after processing, for ease of testing
    end

    def apply_metadata_to_uploaded_file(uploaded_file, params)
      filename = get_filename_for_uploaded_file(uploaded_file, params)
      # We are relying on the fact that only supplemental_files are showing up in
      # the selected_files params for browse_everything in order to distinguish
      # between primary and supplemental browse_everything files. This probably isn't a
      # safe assumption long-term.
      if filename.nil? || params["etd"]["supplemental_file_metadata"].nil?
        uploaded_file.pcdm_use = ::FileSet::PRIMARY
        uploaded_file.save
        return true
      end
      supplemental_file_metadata = get_supplemental_file_metadata(filename, params)
      uploaded_file.title = supplemental_file_metadata["title"]
      uploaded_file.description = supplemental_file_metadata["description"]
      uploaded_file.file_type = supplemental_file_metadata["file_type"]
      uploaded_file.pcdm_use = ::FileSet::SUPPLEMENTAL
      uploaded_file.save
    end

    # @param [String] filename
    # @param [Hash] params
    # @return [Hash]
    def get_supplemental_file_metadata(filename, params)
      supplemental_file_metadata = params["etd"]["supplemental_file_metadata"].values
      supplemental_file_metadata.select { |a| a["filename"] == filename }.first
    end

    def get_filename_for_uploaded_file(uploaded_file, params)
      return File.basename(uploaded_file.file.file.file) if uploaded_file.file.file
      get_file_for_url(uploaded_file.browse_everything_url, params)
    end

    # Given a browse everything url, return the file name
    def get_file_for_url(url, params)
      selected_files = params["selected_files"].values
      return unless selected_files.map { |a| a["url"] }.include?(url)
      selected_files.select { |a| a["url"] == url }.first["file_name"]
    end

    # Given a filename, return the browse everything url
    def get_url_for_filename(filename, params)
      selected_files = params["selected_files"].values
      selected_files.select { |a| a["file_name"] == filename }.first["url"]
    end

    # Locally uploaded files should already have a Hyrax::UploadedFile object.
    # If the uploaded_file_id starts with http, then it must be a
    # BrowseEverything file. Put the id in the browse_everything_url field.
    # @param [String] uploaded_file_id
    # @return [::Hyrax::UploadedFile]
    def find_or_create_uploaded_file(uploaded_file_id)
      return ::Hyrax::UploadedFile.find(uploaded_file_id) unless uploaded_file_id.starts_with?("http")
      ::Hyrax::UploadedFile.create(browse_everything_url: uploaded_file_id)
    end
  end
end
