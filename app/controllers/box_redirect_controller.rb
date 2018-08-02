class BoxRedirectController < ApplicationController
  def redirect_file
    conn = Faraday.new(url: "https://api.box.com/2.0/files/#{params[:id]}/content")
    response = conn.get do |req|
      req.headers['Authorization'] = "Bearer #{params[:token]}"
    end
    render json: response.env.response_headers
  end
end
