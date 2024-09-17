module Hyrax
  ##
  # A custom authority service with optional `active:` tags.
  #
  # Active flag in qa is meant to be optional, with a default of `true`. This
  # module reinstates that as a strict subclass of `Hyrax::QaSelectService`.
  #
  # @see https://github.com/samvera/questioning_authority/#list-of-id-and-term-keys-and-optionally-active-key
  class LaevigataAuthorityService < Hyrax::QaSelectService
    class << self
      ##
      # Builds an authority service for a given school or department.
      #
      # Given a school, a deparmental authority service is returned with the
      # appropriate deparments within that school. Given a department, a
      # subfield authority service is returned representing the subfields
      # within the department.
      #
      # If both are given, an argument error is raised.
      #
      # @overload for(school:)
      #   @param [#=~] school
      #   @return [LaevigataAuthorityService] a departmental authority service
      # @overload for(departement:)
      #   @param [#=~] department
      #   @return [LaevigataAuthorityService] a subfield authority service
      #
      # @raise [ArgumentError] when both a school and department are given.
      def for(school: nil, department: nil)
        authority_name = programs_for(school) if school && !department
        authority_name = subfields_for(department) if department && !school

        return Hyrax::QaSelectService.new(authority_name) if authority_name
        return nil if school.present? ^ department.present?

        raise(ArgumentError,
              "Expected one of school or department. Got school: #{school}; department: #{department}")
      end

      private

      # Map program/department authories for each school based on the 'programs' field in the school authority
      def programs_for(school)
        @program_map ||= load_program_mappings
        @program_map[school]
      end

      # Map subfields to departments for selected departments
      # only a subset of departments have subfields
      def subfields_for(department)
        @subfield_map ||= load_subfield_mappings
        @subfield_map[department]
      end

      def load_subfield_mappings
        departments = JSON.load_file(Rails.root.join('app', 'javascript', 'config', 'subfieldEndpoints.json'))
        departments.map { |dept, path| [dept, path.split('/').last] }.to_h
      end

      def load_program_mappings
        # TODO - refactor to avoid calling private method
        school_authority = Qa::Authorities::Local.registry.instance_for('school')
        school_authority.send(:terms).map { |t| [t['term'], t['programs']] }.to_h
      end
    end

    # override parent to default entries to active when key is absent
    def active?(id)
      authority.find(id)&.fetch('active', true)
    end

    # override parent to default entries to active when key is absent
    def active_elements
      authority.all.select { |e| e.fetch('active', true) }
    end
  end
end
