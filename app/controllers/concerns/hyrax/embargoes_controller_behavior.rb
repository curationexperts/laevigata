module Hyrax
  module EmbargoesControllerBehavior
    extend ActiveSupport::Concern
    include Hyrax::ManagesEmbargoes
    include Hyrax::Collections::AcceptsBatches

    def edit
      super
      authorize! :edit, Hydra::AccessControls::Embargo
    end
  end
end
