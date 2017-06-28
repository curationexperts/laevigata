# services/degree_service.rb
module Hyrax
  class FiletypeService < Hyrax::QaSelectService
    def initialize
      super('filetype')
    end
  end
end
