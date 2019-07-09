# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PagesController do
  it 'has a flash alert & 404' do
    get :error_404
    expect(flash[:alert]).not_to be(nil)
    expect(response).to have_http_status(404)
  end
end
