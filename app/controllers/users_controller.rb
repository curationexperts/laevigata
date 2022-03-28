# frozen_string_literal: true
class UsersController < ApplicationController
  before_action :ensure_admin!
  before_action :load_user
  with_themed_layout 'dashboard'

  def activate
    @user.update(params.permit(:deactivated))
    flash[:notice] = params[:deactivated] == "true" ? "User deactivated" : "User reactivated"
    redirect_to hyrax.admin_users_path
  end

  private

  def load_user
    @user = User.find(params[:id])
  end

  def ensure_admin!
    authorize! :read, :admin_dashboard
  end
end
