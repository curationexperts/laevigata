module Hyrax
  module Actors
    ##
    # Sets `env.attributes[:visibility] to
    # `Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC`
    # ("open") if a visibility is not already explictly set.
    #
    # This actor operates o
    class PublicVisibilityActor < AbstractActor
      DEFAULT_VISIBILITY = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC

      def create(env)
        (env.attributes[:visibility] ||= DEFAULT_VISIBILITY) &&
          next_actor.create(env)
      end
    end
  end
end
