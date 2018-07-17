module Hyrax
  module Actors
    # Attaches remote files to the work
    class CreateWithRemoteFilesActor < Hyrax::Actors::AbstractActor
      attr_accessor :curation_concern

      def create(env)
        remote_files = env.attributes.delete(:remote_files)
        next_actor.create(env) && attach_files(env, remote_files)
      end

      def update(env)
        remote_files = env.attributes.delete(:remote_files)
        next_actor.update(env) && attach_files(env, remote_files)
      end

      def self.needs_attr_accessible?
        true
      end

      protected

        def whitelisted_ingest_dirs
          Hyrax.config.whitelisted_ingest_dirs
        end

        # @param uri [URI] the uri fo the resource to import
        def validate_remote_url(uri)
          if uri.scheme == 'file'
            path = File.absolute_path(CGI.unescape(uri.path))
            whitelisted_ingest_dirs.any? do |dir|
              path.start_with?(dir) && path.length > dir.length
            end
          else
            # TODO: It might be a good idea to validate other URLs as well.
            #       The server can probably access URLs the user can't.
            true
          end
        end

        # @param [HashWithIndifferentAccess] remote_files
        # @return [TrueClass]
        def attach_files(env, remote_files)
          return true unless remote_files
          remote_files.each do |file_info|
            next if file_info.blank? || file_info[:url].blank?
            # Escape any space characters, so that this is a legal URI
            uri = URI.parse(Addressable::URI.escape(file_info[:url]))
            unless validate_remote_url(uri)
              Rails.logger.error "User #{env.user.user_key} attempted to ingest file from url #{file_info[:url]}, which doesn't pass validation"
              return false
            end
            auth_header = file_info.fetch(:auth_header, {})
            create_file_from_url(env, uri, file_info[:file_name], auth_header)
          end
          true
        end

        # Generic utility for creating FileSet from a URL
        # Used in to import files using URLs from a file picker like browse_everything
        def create_file_from_url(env, uri, file_name, _auth_header = {})
          ::FileSet.new(import_url: uri.to_s, label: file_name) do |fs|
            actor = Hyrax::Actors::FileSetActor.new(fs, env.user)
            actor.create_metadata(visibility: env.curation_concern.visibility)
            actor.attach_to_work(env.curation_concern)
            apply_saved_metadata(fs, env.curation_concern)
            fs.save!
            if uri.scheme == 'file'
              # Turn any %20 into spaces.
              file_path = CGI.unescape(uri.path)
              IngestLocalFileJob.perform_later(fs, file_path, env.user)
            else
              ImportUrlJob.perform_later(fs, operation_for(user: actor.user))
            end
          end
        end

        # We created a temporary Hyrax::UploadedFile for each browse_everything
        # file at the time of form submission (see etds_controller.rb).
        # Go find that object, and apply its metadata to the FileSet that just got
        # created. This duplicates for browse_everything objects the same behavior
        # that happens for local uploads in AttachFilesToWorkJob.
        # TODO: Should we delete this temporary ::Hyrax::UploadedFile object when we're
        # done with it? Is there ever a cleanup job?
        # @param [FileSet] fs
        # @param [Work] curation_concern
        def apply_saved_metadata(fs, curation_concern)
          uf = ::Hyrax::UploadedFile.where(browse_everything_url: fs.import_url).first
          if uf&.pcdm_use == ::FileSet::PRIMARY
            fs.pcdm_use = ::FileSet::PRIMARY
            fs.title = curation_concern.title
          else
            fs.pcdm_use = ::FileSet::SUPPLEMENTAL
            fs.title = Array.wrap(uf&.title)
            fs.description = Array.wrap(uf&.description)
            fs.file_type = uf&.file_type
          end
          fs.save
        end

        def operation_for(user:)
          Hyrax::Operation.create!(user: user,
                                   operation_type: "Attach Remote File")
        end
    end
  end
end
