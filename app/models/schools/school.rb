# frozen_string_literal: true

# This class collects the config information about a
# school into one place so that it can easily be
# displayed.
#
# This class is not meant to be used to edit or set
# any of the config values.  It is for display only.

module Schools
  class School
    # Find the QA terms for all active schools.
    def self.active_elements
      ss = Hyrax::SchoolService.new
      ss.active_elements
    end

    # @param id [String]: The ID for the school (as defined in config/authorities/school.yml)
    def initialize(id)
      @id = id
    end
    attr_reader :id

    def label
      return @label if @label
      ss = Hyrax::SchoolService.new
      qa_terms = ss.active_elements.find { |school| school['id'] == id } || {}
      @label = qa_terms[:label]
    end

    def service
      @service ||= Hyrax::LaevigataAuthorityService.for(school: id)
    end

    def department_ids
      return [] unless service
      qa_terms = service.authority.all
      qa_terms.map { |terms| terms[:id] }
    end

    # @return [Array<Schools::Department>] The departments for this school.
    def departments
      @departments ||= department_ids.map do |dept_id|
        Schools::Department.new(self, dept_id)
      end
    end

    def as_chooser
      @as_chooser ||= ::AdminSetChooser.new
    end

    # @return [Array<AdminSet>] All AdminSet records.
    #
    # Fetch all the AdminSet records so they will be
    # available for this school's departments and
    # sub-fields without having to do multiple queries
    def all_admin_sets
      @all_admin_sets ||= AdminSet.all.to_a
    end

    # @return [AdminSet] The AdminSet for this school (if it has one)
    def admin_set
      return @admin_set if @admin_set
      as_name = as_chooser.determine_admin_set([id], [], [])
      return nil unless as_name
      @admin_set = all_admin_sets.find { |as| as.title.include?(as_name) }
    end
  end
end
