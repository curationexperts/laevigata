# frozen_string_literal: true

# This class is not meant to be used to edit or set
# any of the config values.  It is for display only.
# See the School class for more info.

module Schools
  class Subfield
    # @param school [Schools::School]: The school this subfield belongs to.
    # @param department [Schools::Department]: The department this subfield belongs to.
    # @param id [String]: The ID for the subfield (as defined in config/authorities/<department>_programs.yml)
    def initialize(school, department, id)
      @school = school
      @department = department
      @id = id
    end
    attr_reader :school, :department, :id

    def department_service
      department.service
    end

    def label
      return @label if @label
      qa_terms = department_service.active_elements.find { |subfield| subfield['id'] == id } || {}
      @label = qa_terms[:label]
    end
  end
end
