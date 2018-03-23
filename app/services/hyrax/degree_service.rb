# services/degree_service.rb
module Hyrax
  class DegreeService < LaevigataAuthorityService
    def initialize
      super('degree')
    end
  end
end
