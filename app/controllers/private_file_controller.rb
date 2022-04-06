class PrivateFileController < ApplicationController
  before_action :ensure_admin!

  # sends a file from the private filesystem
  def download
    send_file(Rails.root.join("private", [params[:file_name], '.', params[:format]].join))
  end

  private

  def ensure_admin!
    authorize! :read, :admin_dashboard
  end
end
