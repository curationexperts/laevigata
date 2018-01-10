module Hyrax
  class BusinessService < Hyrax::QaSelectService
    def initialize
      super('business_programs')
    end
  end
end
