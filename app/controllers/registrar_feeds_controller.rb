class RegistrarFeedsController < ApplicationController
  before_action :set_registrar_feed, only: %i[show edit update destroy graduation_records report]
  before_action :auth
  layout 'hyrax/dashboard'

  # GET /registrar_feeds or /registrar_feeds.json
  def index
    @registrar_feeds = RegistrarFeed.by_recently_updated
  end

  # GET /registrar_feeds/1 or /registrar_feeds/1.json
  def show; end

  # GET /registrar_feeds/1/graduation_records
  def graduation_records
    download_for(@registrar_feed.graduation_records)
  end

  # GET /registrar_feeds/1/report
  def report
    download_for(@registrar_feed.report)
  end

  # GET /registrar_feeds/new
  def new
    @registrar_feed = RegistrarFeed.new
  end

  # GET /registrar_feeds/1/edit
  def edit; end

  # POST /registrar_feeds or /registrar_feeds.json
  def create
    @registrar_feed = RegistrarFeed.new(registrar_feed_params)

    respond_to do |format|
      if @registrar_feed.save
        format.html { redirect_to registrar_feeds_path, notice: "Registrar feed was successfully created." }
        format.json { render :show, status: :created, location: @registrar_feed }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @registrar_feed.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /registrar_feeds/1 or /registrar_feeds/1.json
  def update
    respond_to do |format|
      if @registrar_feed.update(registrar_feed_params)
        format.html { redirect_to @registrar_feed, notice: "Registrar feed was successfully updated." }
        format.json { render :show, status: :ok, location: @registrar_feed }
      else
        format.html { render :show, status: :unprocessable_entity }
        format.json { render json: @registrar_feed.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /registrar_feeds/1 or /registrar_feeds/1.json
  def destroy
    @registrar_feed.destroy
    respond_to do |format|
      format.html { redirect_to registrar_feeds_url, notice: "Registrar feed was successfully destroyed." }
      format.json { head :no_content }
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
      # The file field, which is the only field ont the form, may be submitted empty
      # See https://github.com/rails/rails/issues/17947#issuecomment-225154294
      params.fetch(:registrar_feed, {}).permit(:graduation_records)
    end

    # Restrict to authorized admins
    def auth
      authorize! :manage, RegistrarFeed
    end

    # Provide authenticated download for attachments
    def download_for(attachment)
      send_data(attachment.blob.download, filename: attachment.filename.to_s, disposition: 'attachment') if attachment.attached?
    end
end
