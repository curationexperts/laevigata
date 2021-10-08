module Hyrax
  module Actors
    ##
    # Sets pregraduation embargo attributes for interpretation by the rest of
    # the stack.
    class PregradEmbargo < AbstractActor
      DEFAULT_LENGTH = 500.years

      def create(env)
        env.attributes.merge!(pregraduation_embargo_attributes(env)) &&
          next_actor.create(env)
      end

      private

        def pregraduation_embargo_attributes(env)
          return {} unless env.attributes.key?(:requested_embargo_duration)

          return handle_malformed_data(env) if
            env.attributes.fetch(:requested_embargo_duration, nil) == InProgressEtd::NO_EMBARGO

          open = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
          embargo = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO

          { embargo_release_date:      DEFAULT_LENGTH.from_now.to_date.to_s,
            visibility:                embargo,
            visibility_after_embargo:  open,
            visibility_during_embargo: open }
        end

        ##
        # When creating an `Etd` with no embargo, `InProgressEtd` passes a
        # particular string (`InProgressEtd::NO_EMBARGO'). For the moment, we
        # need to handle
        #
        # @todo rework callers to avoid passing this "malformed" data. We
        #   shouldn't need to interpret strings passed to this value until
        #   graduation.
        def handle_malformed_data(env)
          warn "#{self.class} is cleaning up non-date data passed to the " \
               ":embargo_length attribute. #{env.attributes[:requested_embargo_duration]} " \
               "is being interpreted as a request for no embargo on " \
               "#{env.attributes[:title]}."

          # env.attributes.delete(:embargo_length)

          {}
        end
    end
  end
end
