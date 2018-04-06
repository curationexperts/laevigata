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
        return for_school(school)         if school     && !department
        return for_department(department) if department && !school

        raise(ArgumentError,
              "Expected one of school or department. Got school: #{school}; department: #{department}")
      end

      ##
      # @api private
      def for_school(school)
        case school
        when /Emory/
          Hyrax::EmoryService.new
        when /Laney/
          Hyrax::LaneyService.new
        when /Candler/
          Hyrax::CandlerService.new
        when /Rollins/
          Hyrax::RollinsService.new
        end
      end

      ##
      # @api private
      def for_department(department)
        case department
        when 'Business'
          Hyrax::BusinessService.new
        when 'Executive Masters of Public Health - MPH'
          Hyrax::ExecutiveService.new

        # both Biostatistics programs have same sub-fields,
        # returned by the same service
        when 'Biostatistics'
          Hyrax::BiostatisticsService.new
        when 'Biostatistics and Bioinformatics'
          Hyrax::BiostatisticsService.new
        when 'Biological and Biomedical Sciences'
          Hyrax::BiologicalService.new
        when 'Environmental Studies'
          Hyrax::EnvironmentalService.new
        # both Laney and Rollins have Epidemiology departments with same set of sub-fields, returned by the service
        when 'Epidemiology'
          Hyrax::EpidemiologyService.new
        when 'Psychology'
          Hyrax::PsychologyService.new
        when /Religion/
          Hyrax::ReligionService.new
        end
      end
    end

    def active?(id)
      authority.find(id).fetch('active', true)
    end

    def active_elements
      authority.all.select { |e| e.fetch('active', true) }
    end
  end
end
