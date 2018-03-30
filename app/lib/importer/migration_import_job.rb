module Importer
  class MigrationImportJob < ActiveJob::Base
    queue_as :migration

    def perform(record, source_host, error_stream, info_stream)
      pid    = record
      record = Darlingtonia::InputRecord
                 .from(metadata: record,
                       mapper:   Importer::MigrationMapper.new(source_host: source_host))

      attributes = record.attributes.dup
      attributes.delete(:pid)

      if attributes[:email]
        user_key = "migration_#{attributes[:email].first.split('@').first}"

        # Create a user and update email/display_name; we can tolerate churn in
        # these attributes in the case of multiple submissions by the same user.
        depositor = User.find_or_create_by(ppid: user_key)
        depositor.update_attributes(email:        attributes[:email].first,
                                    display_name: attributes[:creator]&.first)
      else
        depositor = User.find_or_create_system_user('migration_user')
      end

      binary_file  = record.mapper.primary_file
      primary_file = File.open(tmp_path(binary_file.name), 'w', encoding: 'ascii-8bit')
      primary_file.write(binary_file.content)

      attributes[:uploaded_files] =
        [Hyrax::UploadedFile.create(user: depositor, file: primary_file, pcdm_use: FileSet::PRIMARY).id]

      primary_file.close
      File.unlink(primary_file)

      record.mapper.original_files
        .each_with_object(attributes[:uploaded_files]) do |original_binary, files|
        file = File.open(tmp_path(original_binary.name), 'w', encoding: 'ascii-8bit')
        file.write(original_binary.content)

        files <<
          Hyrax::UploadedFile.create(user: depositor, file: file, pcdm_use: FileSet::ORIGINAL).id

        file.close
        File.unlink(file)
      end

      record.mapper
        .supplementary_files
        .each_with_object(attributes[:uploaded_files]) do |supplementary_file, files|
        file = File.open(tmp_path(supplementary_file.name), 'w', encoding: 'ascii-8bit')
        file.write(supplementary_file.content)

        files << Hyrax::UploadedFile.create(user:     depositor,
                                            file:     file,
                                            pcdm_use: FileSet::SUPPLEMENTARY,
                                            title:    supplementary_file.name).id

        file.close
        File.unlink(file)
      end

      premis_file = Tempfile.new(['premis', '.xml'])
      premis_file.write(record.mapper.premis_content)
      attributes[:uploaded_files] << Hyrax::UploadedFile.create(user:     depositor,
                                                                file:     premis_file,
                                                                pcdm_use: FileSet::PREMIS,
                                                                title:    'premis.xml').id

      premis_file.close
      premis_file.unlink

      actor = Hyrax::Actors::ActorStack.new(Etd.new, ::Ability.new(depositor), stack_actors)
      actor.create(attributes)

      info_stream << "INFO: [#{pid}] created."
    rescue Ldp::Error, Faraday::ConnectionFailed => e
      info_stream << "INFO: [#{pid}] soft failed, requeueing.\n#{e.class}:\n\t#{e.message}"
      raise e
    rescue MigrationMapper::MappingError => e
      error_stream << "ERROR: [#{pid}] failed on mapping.\n#{e.class}:\n\t#{e.message}"
    rescue => e
      error_stream << "ERROR: [#{pid}] soft failed, requeueing.\n#{e.class}:\n\t#{e.message}"
      raise e
    end

    def stack_actors
      [Hyrax::Actors::TransactionalRequest,
       Hyrax::Actors::OptimisticLockValidator,
       Hyrax::CreateWithFilesActor,
       Hyrax::Actors::AddAsMemberOfCollectionsActor,
       Hyrax::Actors::AddToWorkActor,
       Hyrax::Actors::AssignRepresentativeActor,
       Hyrax::Actors::AttachFilesActor,
       Hyrax::Actors::AttachMembersActor,
       Hyrax::Actors::ApplyOrderActor,
       Hyrax::Actors::InterpretVisibilityActor,
       SetEmbargoActor,
       ImportAdminSetActor,
       Hyrax::ApplyPermissionTemplateActor,
       Hyrax::Actors::EtdActor,
       Hyrax::Actors::InitializeWorkflowActor]
    end

    def tmp_path(name)
      Pathname.new(Dir.tmpdir).join(name)
    end

    class ImportAdminSetActor < Hyrax::Actors::AbstractActor
      ##
      # @see Hyrax::AbstractActor#create
      def create(attributes)
        attributes[:admin_set_id] = AdminSet.find_or_create_default_admin_set_id
        next_actor.create(attributes)
      end
    end

    class SetEmbargoActor < Hyrax::Actors::AbstractActor
      ##
      # @see Hyrax::AbstractActor#create
      def create(attributes)
        apply_embargo(date: attributes.delete(:embargo_lift_date))
        next_actor.create(attributes)
      end

      private

        def apply_embargo(date:)
          return unless date && date >= Time.zone.today

          curation_concern.apply_embargo(
            date,
            Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
            Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
          )

          return unless curation_concern.embargo
          curation_concern.embargo.save
        end
    end
  end
end
