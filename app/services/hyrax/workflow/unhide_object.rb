module Hyrax
  module Workflow
    ##
    # Remove the hidden flag for an object
    #
    # @param target [#state] an instance of a model
    module UnhideObject
      def self.call(target:, **)
        target.hidden = false
        target.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
        target.members.each do |fs|
          fs.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
          fs.save
        end
      end
    end
  end
end
