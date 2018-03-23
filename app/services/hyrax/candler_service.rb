# services/emory_service.rb
module Hyrax
  class CandlerService < LaevigataAuthorityService
    def initialize
      super('candler_programs')
    end
  end
end
