# services/partners_service.rb
module Hyrax
  class PartnersService < Hyrax::QaSelectService
    def initialize
      super('partnering_agencies')
    end
  end
end
