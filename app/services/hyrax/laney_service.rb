# services/laney_service.rb
module Hyrax
  class LaneyService < Hyrax::QaSelectService
    def initialize
      super('laney_programs')
    end
  end
end
