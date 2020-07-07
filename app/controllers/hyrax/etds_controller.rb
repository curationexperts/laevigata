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

    helper EtdHelper

    # Overriding `Hyrax::WorksControllerBehavior`, which wants to use the
    # 'dashboard' theme for all but the show view. Always use the theme instead.
    with_themed_layout nil

    def create
      sanitize_input(params)
      merge_selected_files_hashes(params) if params["selected_files"]
      update_supplemental_files
      update_committee_members
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
      if must_update_file_visibility?(curation_concern)
        Rails.logger.debug("#{self.class} for #{curation_concern.class}: #{curation_concern.id} " \
                           "is about to update the embargos for its FileSets")
        enforce_file_visibility(curation_concern)
      end

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
      sanitize_input(params)
      translate_embargo_string(params)
      merge_selected_files_hashes(params) if params["selected_files"]
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

    def update_committee_members
      # check if user checked the 'no committee members'
      # checkbox, remove any committee members from
      # the committee_members and committee_members_names params,
      # and delete any existing committee members and names that are already
      # attached to the ETD.
      return unless params["etd"]["no_committee_members"] == '1'
      params["etd"]["committee_members_attributes"] = nil
      return if params["id"].blank?
      etd = Etd.find(params["id"])
      etd.committee_members = nil
      etd.committee_members_names = nil
      etd.save
    end

    def update_supplemental_files
      no_supp = params["etd"].delete("no_supplemental_files")
      # If user checked the 'no supplemental files'
      # checkbox, remove any supplemental files from
      # the uploaded_files param, and delete any
      # existing supplemental files that are already
      # attached to the ETD.
      if no_supp == "1"
        if params['uploaded_files']
          supp_file_ids = []
          params['uploaded_files'].each do |id|
            up_file = Hyrax::UploadedFile.find(id)
            next unless up_file
            supp_file_ids << id if up_file.pcdm_use == ::FileSet::SUPPLEMENTARY
          end
          params['uploaded_files'] = params['uploaded_files'] - supp_file_ids
        end

        curation_concern.supplemental_files_fs.each do |supp_file|
          fs_actor = Hyrax::Actors::FileSetActor.new(supp_file, current_user)
          fs_actor.destroy
        end
      else
        apply_file_metadata(params)
      end
    end

    # Take supplemental file metadata and write it to the appropriate UploadedFile
    # @param [ActionController::Parameters] params
    # @return [ActionController::Parameters] params
    def apply_file_metadata(params)
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

      # params['be_pcdm_use_primary'] only gets sent when student uses browse-everything to upload their primary pdf
      if filename == params.fetch('be_pcdm_use_primary', false)
        uploaded_file.pcdm_use = ::FileSet::PRIMARY
        uploaded_file.save
        return true
      end

      supplemental_file_metadata = get_supplemental_file_metadata(filename, params)

      if supplemental_file_metadata.empty?
        Honeybadger.notify "No metadata was assigned for #{filename} on #{params['etd']['title']}\n" \
                           "The uploaded file was: #{uploaded_file.id};\nThe params were: #{params}."
      end

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
      supplemental_file_metadata = params["etd"]["supplemental_file_metadata"]&.values || {}
      supplemental_file_metadata.find { |a| a["filename"].tr(' ', '_') == filename.tr(' ', '_') } || {}
    end

    def get_filename_for_uploaded_file(uploaded_file, params)
      return File.basename(uploaded_file.file.file.file) if uploaded_file.file.file
      get_file_for_url(uploaded_file.browse_everything_url, params)
    end

    # We create more than one selected_files* hash on the front end, via two instances of the browse-everything uploader
    # We need to find them and merge them into one hash in the structure the rest of the application expects

    # @params [Hash] params
    # @return [Hash] selected_files
    def merge_selected_files_hashes(params)
      selected_files = {}
      be_files = params.fetch('selected_files', false)

      count_of_files = 0
      index = 0

      # Get count of all browse-everything selected_files
      be_files[0].each_key { |k| count_of_files += be_files[0][k].size }

      # Populate the selected_files hash with all of the browse-everything files, with keys in the structure the rest of the application will expect: their indexes converted to strings
      be_files[0].each_key do |k|
        be_files[0][k].each do |ke, va| # rubocop:disable Style/HashEachMethods
          if index < count_of_files
            selected_files[index.to_s] = va
            index += 1
          end
        end
      end # rubocop:enable Style/HashEachMethods

      # Add the full hash under the key the rest of the app expects
      params[:selected_files] = selected_files
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

    private

      def translate_embargo_string(params)
        return unless params['etd']['embargo_type']
        embargo_booleans = params['etd']['embargo_type'].split(',').map { |type| ActiveModel::Type::Boolean.new.cast(type).to_s }
        etd = Etd.find(params["id"])
        case embargo_booleans
        when ['true']
          etd.files_embargoed = 'true'
          etd.toc_embargoed = 'false'
          etd.abstract_embargoed = 'false'
          etd.save
        when ['true', 'true']
          etd.files_embargoed = 'true'
          etd.toc_embargoed = 'true'
          etd.abstract_embargoed = 'false'
          etd.save
        when ['true', 'true', 'true']
          etd.files_embargoed = 'true'
          etd.toc_embargoed = 'true'
          etd.abstract_embargoed = 'true'
          etd.save
        end
      end

      def must_update_file_visibility?(work)
        work.file_sets.present? &&
          (permissions_changed? || work.visibility_changed?) ||
          (Rails.logger.debug("#{self.class} for #{curation_concern.class}: #{curation_concern.id} " \
                             "declined to update its FileSet embargoes. " \
                             "\n\t`work.file_sets.present?`: #{work.file_sets.present?}" \
                             "\n\t`permissions_changed?`: #{permissions_changed?}" \
                             "\n\t`work.visibility_changed?`: #{work.visibility_changed?}") &&
           false) # keep false value when logging
      end

      def enforce_file_visibility(work)
        visibility_attrs =
          FileSetVisibilityAttributeBuilder
            .new(work: work)
            .build

        work.file_sets.each do |fs|
          Hyrax::Actors::FileSetActor
            .new(fs, current_user)
            .update_metadata(visibility_attrs) ||
            Rails.logger.debug("#{self.class} for #{work.class}: #{work.id} " \
                               "tried to update the embargo for #{fs.class}: " \
                               "#{fs.id}." \
                               "\n\tUpdate failed with a `false` return value " \
                               'from `Hyrax::Actors::FileSetActor#update_metadata`.' \
                               "\n\tThe visibility attributes were: #{visibility_attrs}." \
                               "\n\tThe existing embargo is #{fs.embargo}." \
                               "\n\tFIGURE OUT HOW TO REMOVE ME FROM THE LOG.")
        end
      end
  end
end
