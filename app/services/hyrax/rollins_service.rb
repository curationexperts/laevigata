# services/rollins_service.rb
module Hyrax
  class RollinsService < LaevigataAuthorityService
    def initialize
      super('rollins_programs')
    end
  end
end
