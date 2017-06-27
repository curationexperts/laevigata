module Hyrax
  class PsychologyService < Hyrax::QaSelectService
    def initialize
      super('psychology_programs')
    end
  end
end
