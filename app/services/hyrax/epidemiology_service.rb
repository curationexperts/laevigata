module Hyrax
  class EpidemiologyService < Hyrax::QaSelectService
    def initialize
      super('epidemiology_programs')
    end
  end
end
