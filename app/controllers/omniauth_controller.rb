class SessionsController < Devise::SessionsController
  def new
    Rails.logger.debug "SessionsController#new: request.referer = #{request.referer}"
    store_location_for(:user, request.referer) # return to previous page after authn
    redirect_to user_omniauth_authorize_path(:shibboleth)
    # if Ddr::Auth.require_shib_user_authn
    # remove "sign in or sign up" flash alert from Devise failure app
    #   flash.discard(:alert)
    #   redirect_to user_omniauth_authorize_path(:shibboleth)
    # else
    #   super
    # end
  end

  def after_sign_out_path_for(scope)
    return Ddr::Auth.sso_logout_url if Ddr::Auth.require_shib_user_authn
    super
  end
end
