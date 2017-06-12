# services/emory_service.rb
module Hyrax
  class CandlerService < Hyrax::QaSelectService
    def initialize
      super('candler_programs')
    end
  end
end
