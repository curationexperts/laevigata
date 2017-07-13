module Hyrax
  # Copied from Hyrax to override the assignment of admin set.
  # The admin set is determined by the school and department instead of by explicitly
  # naming the admin set. Unlike the default Hyrax behavior, there is no "default" admin set.
  # This should come before the Hyrax::Actors::InitializeWorkflowActor, so that the correct
  # workflow can be kicked off.
  #
  # @note Creates AdminSet, Hyrax::PermissionTemplate, Sipity::Workflow (with activation)
  class DefaultAdminSetActor < Hyrax::Actors::AbstractActor
    def create(attributes)
      ensure_admin_set_attribute!(attributes)
      next_actor.create(attributes)
    end

    def update(attributes)
      ensure_admin_set_attribute!(attributes)
      next_actor.update(attributes)
    end

    private

      def ensure_admin_set_attribute!(attributes)
        school = attributes["school"] ? attributes["school"] : curation_concern.school
        department = attributes["department"] ? attributes["department"] : curation_concern.department
        curation_concern.assign_admin_set(school, department)
        attributes[:admin_set_id] = curation_concern.admin_set.id
      end
  end
end
