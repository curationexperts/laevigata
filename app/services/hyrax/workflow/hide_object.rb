module Hyrax
  module Workflow
    ##
    # Mark an object hidden. It will never be displayed to the public, only
    # visible to superusers and school approvers.
    #
    # @param target [#state] an instance of a model
    module HideObject
      def self.call(target:, **)
        target.hidden = true
        target.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
        target.members.each do |fs|
          fs.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
          fs.save
        end
      end
    end
  end
end
