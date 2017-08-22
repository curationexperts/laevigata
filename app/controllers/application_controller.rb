class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include Hydra::Controller::ControllerBehavior

  # Adds Hyrax behaviors into the application controller
  include Hyrax::Controller
  include Hyrax::ThemedLayoutController
  with_themed_layout '1_column'

  protect_from_forgery with: :exception

  # Override from Hyrax
  # Provide a place for Devise to send the user to after signing in
  # Send newly signed in users to the submission form
  def user_root_path
    new_hyrax_etd_path
  end
end
