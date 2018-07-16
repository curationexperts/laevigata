module Hyrax
  module Actors
    ##
    # Sets pregraduation embargo attributes for interpretation by the rest of
    # the stack.
    class PregradEmbargo < AbstractActor
      def create(env)
        env.attributes.merge!(pregraduation_embargo_attributes(env)) &&
          next_actor.create(env)
      end

      private

        def pregraduation_embargo_attributes(env)
          return {} unless env.attributes.key?(:embargo_length)

          open = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
          embargo = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO

          { embargo_release_date:      (Time.zone.today + 6.years).to_s,
            visibility:                embargo,
            visibility_after_embargo:  open,
            visibility_during_embargo: open }
        end
    end
  end
end
