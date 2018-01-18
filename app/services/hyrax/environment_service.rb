module Hyrax
  class EnvironmentService < Hyrax::QaSelectService
    def initialize
      super('environment_programs')
    end
  end
end
