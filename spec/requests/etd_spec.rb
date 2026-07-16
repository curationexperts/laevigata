require 'rails_helper'

RSpec.describe 'concerns/etds', type: :request do
  it "renders the show page" do
    etd = FactoryBot.create(:etd)
    get hyrax_etd_path(etd)
    expect(response).to have_http_status(:success)
  end

  it "returns 404 for a non-existent record", :aggregate_failures do
    get hyrax_etd_path('invalid-id')
    expect(response).to redirect_to page_not_found_path(locale: nil)
    follow_redirect!
    expect(response).to have_http_status(:not_found)
    expect(response.body).to include "The page you were looking for does not exist"
  end
end
