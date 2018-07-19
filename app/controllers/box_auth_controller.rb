class BoxAuthController < ApplicationController
  def auth
    @response = HTTParty.post("https://api.box.com/oauth2/token",
                              body: {
                                'grant_type': 'authorization_code',
                                'code': params[:code],
                                'client_id': ENV['BOX_OAUTH_CLIENT_ID'],
                                'client_secret': ENV['BOX_OAUTH_CLIENT_SECRET']
                              },
                              headers: {
                                'Content-Type:' => 'application/x-www-form-urlencoded'
                              })
    redirect_to "/in_progress_etds/#{params[:state]}/edit?locale=en&access_token=#{@response.parsed_response['access_token']}"
  end

  private

    def box_auth_params
      params.require(:ipe)
      params.require(:code)
    end
end
