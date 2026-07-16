require 'rails_helper'

RSpec.describe '/collection ', type: :request do
  it "returns 404 for a non-existent collections", :aggregate_failures do
    get hyrax.collection_path('invalid-id')
    expect(response).to redirect_to page_not_found_path(locale: nil)
    follow_redirect!
    expect(response).to have_http_status(:not_found)
    expect(response.body).to include "The page you were looking for does not exist"
  end
end
