module Hyrax
  class ExecutiveService < Hyrax::QaSelectService
    def initialize
      super('executive_programs')
    end
  end
end
