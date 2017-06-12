module Hyrax
  class PsychologyService < Hyrax::QaSelectService
    def initialize
      super('psychology_subfield')
    end
  end
end
