# services/rollins_service.rb
module Hyrax
  class RollinsService < Hyrax::QaSelectService
    def initialize
      super('rollins_programs')
    end
  end
end
