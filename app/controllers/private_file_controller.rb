class PrivateFileController < ApplicationController
  before_action :ensure_admin!

  # sends a file from the private filesystem
  def download
    filename = [params[:file_name], '.', params[:format]].join
    base, suffix = filename.split(".")
    send_file(Rails.root.join("private", filename), filename: "#{base}_#{Time.zone.now.strftime('%Y%m%d')}.#{suffix}")
  end

  private

  def ensure_admin!
    authorize! :read, :admin_dashboard
  end
end
