module Hyrax
  module Actors
    # Copied from Hyrax to override the assignment of admin set.
    # The admin set is determined by the school and department instead of by explicitly
    # naming the admin set. Unlike the default Hyrax behavior, there is no "default" admin set.
    # This should come before the Hyrax::Actors::InitializeWorkflowActor, so that the correct
    # workflow can be kicked off.
    #
    # @note Creates AdminSet, Hyrax::PermissionTemplate, Sipity::Workflow (with activation)
    class DefaultAdminSetActor < Hyrax::Actors::AbstractActor
      attr_accessor :curation_concern

      def create(attributes)
        if attributes.is_a? Hyrax::Actors::Environment
          env                   = attributes
          attributes            = env.attributes
          self.curation_concern = env.curation_concern
        end

        ensure_admin_set_attribute!(attributes)
        next_actor.create(env)
      end

      def update(attributes)
        if attributes.is_a? Hyrax::Actors::Environment
          env                   = attributes
          attributes            = env.attributes
          self.curation_concern = env.curation_concern
        end

        ensure_admin_set_attribute!(attributes)
        next_actor.update(env)
      end

      class ResolutionError < ArgumentError
        attr_reader :school, :department, :work

        def initialize(msg = "Could not assign admin_set.",
                       work = nil,
                       school = nil,
                       department = nil)
          @department = department
          @school     = school
          @work       = work

          super(msg + "\n\tSchool: #{school}; Department: #{department}; Work ID: #{work.id}")
        end
      end

      private

        def ensure_admin_set_attribute!(attributes)
          school = attributes["school"] ? attributes["school"] : curation_concern.school
          department = attributes["department"] ? attributes["department"] : curation_concern.department
          curation_concern.assign_admin_set(school, department)
          raise ResolutionError.new("Could not assign admin_set for: ", curation_concern, school.to_a, department.to_a) if
            curation_concern.admin_set.nil?
          attributes[:admin_set_id] = curation_concern.admin_set.id
        end
    end
  end
end
