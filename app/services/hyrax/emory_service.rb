# services/emory_service.rb
module Hyrax
  class EmoryService < LaevigataAuthorityService
    def initialize
      super('emory_programs')
    end
  end
end
