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
      apply_supplemental_file_metadata(params) if params["etd"]["supplemental_file_metadata"]
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
    def apply_supplemental_file_metadata(params)
      byebug
      no_supplemental_files = params["etd"].delete("no_supplemental_files")
      return if no_supplemental_files == 1
      uploaded_file_ids = params["uploaded_files"]
      return if uploaded_file_ids.nil?
      uploaded_file_ids.each do |uploaded_file_id|
        uploaded_file = Hyrax::UploadedFile.find(uploaded_file_id)
        next if uploaded_file.pcdm_use == "primary"
        supplemental_file_metadata = params["etd"]["supplemental_file_metadata"]
        supplemental_file_metadata.keys.each do |key|
          next unless File.basename(uploaded_file.file.file.file) == supplemental_file_metadata[key]["filename"]
          uploaded_file.title = supplemental_file_metadata[key]["title"]
          uploaded_file.description = supplemental_file_metadata[key]["description"]
          uploaded_file.file_type = supplemental_file_metadata[key]["file_type"]
          uploaded_file.save
          supplemental_file_metadata.delete(key)
        end
      end
      params["etd"].delete("supplemental_file_metadata")
      params # return the params after processing, for ease of testing
    end
  end
end
