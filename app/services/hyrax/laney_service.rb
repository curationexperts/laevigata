# services/laney_service.rb
module Hyrax
  class LaneyService < LaevigataAuthorityService
    def initialize
      super('laney_programs')
    end
  end
end
