module Hyrax
  class BiostatisticsService < Hyrax::QaSelectService
    def initialize
      super('biostatistics_programs')
    end
  end
end
