module Hyrax
  class ReligionService < Hyrax::QaSelectService
    def initialize
      super('religion_subfield')
    end
  end
end
