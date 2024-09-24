# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PagesController do
  it 'has a expected status and links', :aggregate_failures do
    get :error_404
    expect(flash).to be_empty
    expect(response).to have_http_status(404)
    expect(response).to render_template 'pages/error_404'
  end
end
