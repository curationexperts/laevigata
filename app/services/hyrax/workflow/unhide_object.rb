module Hyrax
  module Workflow
    ##
    # Remove the hidden flag for an object
    #
    # @param target [#state] an instance of a model
    module UnhideObject
      def self.call(target:, **)
        target.hidden = false
      end
    end
  end
end
