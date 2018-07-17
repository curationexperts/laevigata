module Hyrax
  module Actors
    class FileVisibilityAttributesActor < AbstractActor
      def create(env)
        next_actor.create(env) && attributes_for_file_sets(env)
      end

      def update(env)
        next_actor.update(env) && attributes_for_file_sets(env)
      end

      private

        # Set embargo visibility to 'private' for file sets;
        # otherwise set visibility visibility to 'open' and don't set embargo for files
        def attributes_for_file_sets(env)
          if env.curation_concern.files_embargoed
            env.attributes[:visibility] =
              Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO
            env.attributes[:visibility_during_embargo] =
              Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
          else
            env.attributes.except!(:visibility, :embargo_release_date)

            env.attributes[:visibility] =
              Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
          end

          true
        end
    end
  end
end
