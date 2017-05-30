# services/partners_service.rb
module Hyrax
  class PartnersService < Hyrax::QaSelectService
    def initialize
      super('partnering_agencies')
    end

    def include_current_value(value, _index, render_options, html_options)
      unless value.blank? || active?(value)
        html_options[:class] << ' force-select'
        render_options += [[label(value), value]]
      end
      [render_options, html_options]
    end
  end
end
