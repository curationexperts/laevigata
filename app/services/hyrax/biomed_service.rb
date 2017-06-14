module Hyrax
  class BiomedService < Hyrax::QaSelectService
    def initialize
      super('biomed_subfield')
    end
  end
end
