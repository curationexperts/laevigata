class SessionsController < Devise::SessionsController
  def new
    # Rails.logger.debug "SessionsController#new: request.referer = #{request.referer}"
    if Rails.env.production?
      redirect_to user_omniauth_authorize_path(:shibboleth)
    else
      super
    end
  end
end
