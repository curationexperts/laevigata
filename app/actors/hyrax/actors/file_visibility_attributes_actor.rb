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
          visibility_attributes =
            FileSetVisibilityAttributeBuilder
              .new(work: env.curation_concern)
              .build

          env.attributes.merge!(visibility_attributes)

          env.attributes.except!(:embargo_release_date) unless
            env.curation_concern.files_embargoed

          true
        end
    end
  end
end
