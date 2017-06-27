module Hyrax
  class BiomedService < Hyrax::QaSelectService
    def initialize
      super('biological_programs')
    end
  end
end
