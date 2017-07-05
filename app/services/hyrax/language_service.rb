module Hyrax
  class LanguageService < Hyrax::QaSelectService
    def initialize
      super('languages_list')
    end
  end
end
