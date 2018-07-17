module Hyrax
  module Actors
    # Attaches remote files to the work
    class CreateWithRemoteFilesActor < Hyrax::Actors::AbstractActor
      attr_accessor :curation_concern

      def create(env)
        raise ArgumentError unless env.is_a? Hyrax::Actors::Environment

        attributes            = env.attributes
        self.curation_concern = env.curation_concern

        remote_files = attributes.delete(:remote_files)
        next_actor.create(env) && attach_files(remote_files)
      end

      def update(attributes)
        if attributes.is_a? Hyrax::Actors::Environment
          env                   = attributes
          attributes            = env.attributes
          self.curation_concern = env.curation_concern
        end

        remote_files = attributes.delete(:remote_files)
        next_actor.update(env) && attach_files(remote_files)
      end

      def self.needs_attr_accessible?
        true
      end

      protected

        # @param [HashWithIndifferentAccess] remote_files
        # @return [TrueClass]
        def attach_files(remote_files)
          return true unless remote_files
          remote_files.each do |file_info|
            next if file_info.blank? || file_info[:url].blank?
            create_file_from_url(file_info[:url], file_info[:file_name])
          end
          true
        end

        # Generic utility for creating FileSet from a URL
        # Used in to import files using URLs from a file picker like browse_everything
        def create_file_from_url(url, file_name)
          ::FileSet.new(import_url: url, label: file_name) do |fs|
            actor = Hyrax::Actors::FileSetActor.new(fs, user)
            actor.create_metadata(visibility: curation_concern.visibility)
            actor.attach_file_to_work(curation_concern)
            apply_saved_metadata(fs, curation_concern)
            fs.save!
            uri = URI.parse(URI.encode(url))
            if uri.scheme == 'file'
              IngestLocalFileJob.perform_later(fs, URI.decode(uri.path), user)
            else
              ImportUrlJob.perform_later(fs, operation_for(user: user))
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
          if uf.pcdm_use == ::FileSet::PRIMARY
            fs.pcdm_use = ::FileSet::PRIMARY
            fs.title = curation_concern.title
          else
            fs.pcdm_use = ::FileSet::SUPPLEMENTAL
            fs.title = Array.wrap(uf.title)
            fs.description = Array.wrap(uf.description)
            fs.file_type = uf.file_type
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
