class RegistrarFeedsController < ApplicationController
  before_action :set_registrar_feed, only: %i[show edit update destroy graduation_records report]
  before_action :auth
  layout 'hyrax/dashboard'

  # GET /admin/registrar_feeds
  def index
    @registrar_feeds = RegistrarFeed.by_recently_updated
  end

  # GET /admin/registrar_feeds/1/graduation_records
  def graduation_records
    download_for(@registrar_feed.graduation_records)
  end

  # GET /admin/registrar_feeds/1/report
  def report
    download_for(@registrar_feed.report)
  end

  # GET /admin/registrar_feeds/new
  def new
    @registrar_feed = RegistrarFeed.new
  end

  # POST /admin/registrar_feeds
  def create
    @registrar_feed = RegistrarFeed.new(registrar_feed_params)

    if @registrar_feed.save
      RegistrarJob.perform_later(@registrar_feed)
      redirect_to registrar_feeds_path, notice: "Registrar feed was successfully submitted."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_registrar_feed
      @registrar_feed = RegistrarFeed.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def registrar_feed_params
      # params.require(:registrar_feed).permit(:graduation_records)
      # The file field, which is the only field on the form, may be submitted empty
      # See https://github.com/rails/rails/issues/17947#issuecomment-225154294
      params.fetch(:registrar_feed, {}).permit(:graduation_records)
    end

    # Restrict to authorized admins
    def auth
      authorize! :manage, RegistrarFeed
    end

    # Provide authenticated download for attachments
    def download_for(attachment)
      return unless attachment.attached?
      send_data(
        attachment.blob.download,
        filename: attachment.filename.to_s,
        disposition: 'attachment'
      )
    end
end
