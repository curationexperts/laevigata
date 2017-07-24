# See `README_embargos.md` for an explanation of how Laevigata embargoes
# differ from the usual Hyrax behavior
module Hyrax
  module Actors
    class InterpretVisibilityActor < AbstractActor
      def create(attributes)
        @attributes = attributes
        save_embargo_length
        @attributes.delete(:embargo_release_date)
        @attributes[:visibility] = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
        apply_pre_graduation_embargo
        curation_concern.save
        next_actor.create(@attributes)
      end

      def update(attributes)
        @attributes = attributes
        save_embargo_length
        attributes.delete(:embargo_release_date)
        attributes[:visibility] = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
        apply_pre_graduation_embargo
        curation_concern.save
        next_actor.update(attributes)
      end

      private

        # Save embargo_length so we can apply it post-graduation
        def save_embargo_length
          return unless curation_concern.class == Etd
          return unless @attributes[:embargo_release_date]
          curation_concern.embargo_length = @attributes[:embargo_release_date]
        end

        # Parse date from string. Returns nil if date_string is not a valid date
        def parse_date(date_string)
          datetime = Time.zone.parse(date_string) if date_string.present?
          return datetime.to_date unless datetime.nil?
          nil
        end

        # The time specified in the `embargo_length` does not begin until the
        # student has graduated. So, given an embargo length of 6 months, the
        # embargo should end *not* 6 months after the work was deposited, but
        # instead 6 months after the student's graduation. However, at deposit
        # time, we do not know when a student will graduate. Therefore, at the
        # time of deposit, we create an Embargo object and set the expiration
        # date to a placeholder value of `Time.zone.today + 6.years`.
        #
        # During embargo, a record is visible to the public. This is another
        # departure from expected `Embargoable` behavior. The work's `visibility`
        # will be set to `open`, in contrast to setting it to `embargoed`,
        # which would be the usual pattern. Instead, `etd_presenter` and the
        # relevant views check for the existence of an embargo and the
        # authorization of the current user, and display embargoed fields accordingly.
        def apply_pre_graduation_embargo
          return unless curation_concern.class == Etd # don't set a pre-graduation embargo for the FileSet
          return unless curation_concern.embargo_length # don't set a pre-graduation embargo unless there is an embargo length
          six_years_from_today = Time.zone.today + 6.years
          curation_concern.apply_embargo(
            six_years_from_today,
            Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
            Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
          )
          return unless curation_concern.embargo
          curation_concern.embargo.save # see https://github.com/projecthydra/hydra-head/issues/226
        end
    end
  end
end
