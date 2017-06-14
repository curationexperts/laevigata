# services/degree_service.rb
module Hyrax
  class DegreeService < Hyrax::QaSelectService
    def initialize
      super('degree')
    end
  end
end
