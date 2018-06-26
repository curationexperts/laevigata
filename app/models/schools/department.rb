# frozen_string_literal: true

# This class is not meant to be used to edit or set
# any of the config values.  It is for display only.
# See the School class for more info.

module Schools
  class Department
    # @param school [Schools::School]: The school this department belongs to.
    # @param id [String]: The ID for the department (as defined in config/authorities/<school>_programs.yml)
    def initialize(school, id)
      @school = school
      @id = id
    end
    attr_reader :school, :id

    def label
      return @label if @label
      qa_terms = school_service.active_elements.find { |dept| dept['id'] == id } || {}
      @label = qa_terms[:label]
    end

    def school_service
      school.service
    end

    def service
      @service ||= Hyrax::LaevigataAuthorityService.for(department: id)
    end

    def subfield_ids
      return [] unless service
      qa_terms = service.authority.all
      qa_terms.map { |terms| terms[:id] }
    end

    # The subfields that belong to this department
    def subfields
      @subfields ||= subfield_ids.map do |id|
        Schools::Subfield.new(school, self, id)
      end
    end

    delegate :all_admin_sets, to: :school
    delegate :as_chooser, to: :school

    # @return [AdminSet] The AdminSet for this department (if it has one)
    def admin_set
      # Some AdminSets are determined by school, not department.
      return nil if school.admin_set

      return @admin_set if @admin_set
      as_name = as_chooser.determine_admin_set([], [id], [])
      return nil unless as_name
      @admin_set = all_admin_sets.find { |as| as.title.include?(as_name) }
    end
  end
end
