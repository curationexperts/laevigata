# services/submitting_service.rb
module Hyrax
  class SchoolService < Hyrax::QaSelectService
    def initialize
      super('school')
    end
  end
end
