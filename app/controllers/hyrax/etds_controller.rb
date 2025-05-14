# Generated via
#  `rails generate hyrax:work Etd`
require 'input_sanitizer'

module Hyrax
  class EtdsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = Etd
    self.show_presenter = EtdPresenter

    # Overriding `Hyrax::WorksControllerBehavior`, which wants to use the
    # 'dashboard' theme for all but the show view. Always use the theme instead.
    with_themed_layout nil

    def create
      sanitize_input(params)
      apply_file_metadata(params)
      if params['etd'].fetch('ipe_id', false)
        create_with_response_for_form
      else
        super
      end
    end

    def after_create_response
      delete_ipe_record
      super
    end

    ##
    # Our file set visibility behavior is somewhat different from Hyrax's
    # default behavior. When we update work visibility or permissions, we
    # want to ensure that the FileSets are given permissions congruent with
    # the embargo settings. We do this by setting the FileSet visibility using
    # `FileSetActor` directly, inline.
    #
    # We can afford to run this inline, because we don't expect works with
    # dozens or hundreds of FileSets.
    #
    # Overriding this method avoids redirects to confirmation pages when
    # updating the visibility and permissions of a work.
    def after_update_response
      enforce_file_visibility(curation_concern)

      respond_to do |wants|
        wants.html { redirect_to [main_app, curation_concern], notice: "Work \"#{curation_concern}\" successfully updated." }
        wants.json { render :show, status: :ok, location: polymorphic_path([main_app, curation_concern]) }
      end
    end

    # So that the next time a student wants to create
    # a new ETD, they won't have the old values from
    # their old ETD hanging around in the form.
    def delete_ipe_record
      return unless params['etd']['ipe_id']
      return unless InProgressEtd.exists? params['etd']['ipe_id']
      ipe = InProgressEtd.find params['etd']['ipe_id']
      ipe.destroy
    end

    def update
      debugger
      sanitize_input(params)
      apply_file_metadata(params)

      if params['request_from_form'] == 'true'
        curation_concern.committee_chair = nil
        curation_concern.committee_members = nil
        update_with_response_for_form
      else
        super
      end
    end

    def update_with_response_for_form
      if actor.update(actor_environment)
        path = main_app.hyrax_etd_path(curation_concern)
        render json: { redirectPath: path }, status: :ok
      else
        render json: { errors: 'ERROR: Unable to save the ETD' }, status: 422
        # TODO: render json: { errors: curation_concern.errors.messages }, status: 422
      end
    end

    # we return unprocessable entity for Etd-creation errors

    # a record without school and department params will cause a Runtime error during the creation of an admin set

    # if any other StandardErrors occur, we want to catch them, log them and display a friendly message to the user

    def create_with_response_for_form
      if actor.create(actor_environment)
        after_create_response
      else
        render json: { errors: curation_concern.errors.messages }, status: 422
      end
    rescue StandardError => error
      Rails.logger.error("Create from IPE error: #{error}, current_user: #{current_user}")
      Honeybadger.notify(error, error_message: "current_user = #{current_user} #{error.message}")
      render json: { errors: error.to_s }, status: 422
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

    # Any fields coming in through tinymce are likely to be full of ms word
    # type markup that we don't want. Sanitize it.
    def sanitize_input(params)
      params["etd"]["abstract"] = ::InputSanitizer.sanitize(params["etd"]["abstract"]) if params["etd"]["abstract"]
      params["etd"]["table_of_contents"] = ::InputSanitizer.sanitize(params["etd"]["table_of_contents"]) if params["etd"]["table_of_contents"]
    end

    # Take supplemental file metadata and write it to the appropriate UploadedFile
    # @param [ActionController::Parameters] params
    # @return [ActionController::Parameters] params
    def apply_file_metadata(params)
      uploaded_file_ids = params["uploaded_files"]
      return if uploaded_file_ids.nil?
      uploaded_file_ids.each do |uploaded_file_id|
        uploaded_file = ::Hyrax::UploadedFile.find(uploaded_file_id)
        next if uploaded_file.pcdm_use == "primary"
        apply_metadata_to_uploaded_file(uploaded_file, params)
      end
      params["etd"].delete("supplemental_file_metadata")
      params # return the params after processing, for ease of testing
    end

    private

      def must_update_file_visibility?(work)
        work.file_sets.present? &&
          (permissions_changed? || work.visibility_changed?)
      end

      def enforce_file_visibility(work)
        return unless must_update_file_visibility?(work)

        visibility_attrs =
          FileSetVisibilityAttributeBuilder
            .new(work: work)
            .build

        work.file_sets.each do |fs|
          Hyrax::Actors::FileSetActor
            .new(fs, current_user)
            .update_metadata(visibility_attrs)
        end
      end

      def apply_metadata_to_uploaded_file(uploaded_file, params)
        supplemental_file_metadata = get_supplemental_file_metadata(uploaded_file, params)

        uploaded_file.title = supplemental_file_metadata["title"]
        uploaded_file.description = supplemental_file_metadata["description"]
        uploaded_file.file_type = supplemental_file_metadata["file_type"]
        uploaded_file.pcdm_use = ::FileSet::SUPPLEMENTAL
        uploaded_file.save
      end

      def get_supplemental_file_metadata(uploaded_file, params)
        filename = get_filename_for_uploaded_file(uploaded_file)
        supplemental_file_metadata = params["etd"]["supplemental_file_metadata"]&.values || {}
        supplemental_file_metadata.find { |a| a["filename"].tr(' ', '_') == filename.tr(' ', '_') } || {}
      end

      def get_filename_for_uploaded_file(uploaded_file)
        File.basename(uploaded_file.file.file.file)
      end
  end
end
