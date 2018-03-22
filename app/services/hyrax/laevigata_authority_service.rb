module Hyrax
  ##
  # A custom authority service with optional `active:` tags.
  #
  # Active flag in qa is meant to be optional, with a default of `true`. This
  # module reinstates that as a strict subclass of `Hyrax::QaSelectService`.
  #
  # @see https://github.com/samvera/questioning_authority/#list-of-id-and-term-keys-and-optionally-active-key
  class LaevigataAuthorityService < Hyrax::QaSelectService
    def active?(id)
      authority.find(id).fetch('active', true)
    end

    def active_elements
      authority.all.select { |e| e.fetch('active', true) }
    end
  end
end
