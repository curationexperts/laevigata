# frozen_string_literal: true
require_relative './spec_helper'

username = ENV['HTTP_USERNAME'] || 'test'
password = ENV['HTTP_PASSWORD'] || 'test'
hostname = ENV['ETD_HOST']
# use this SSLContext to use https URLs without verifying certificates
# @ssl_context = OpenSSL::SSL::SSLContext.new
# @ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
ssl_context = OpenSSL::SSL::SSLContext.new
ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
front_page_url = "https://#{username}:#{password}@#{hostname}"

RSpec.describe "The ETD server at #{hostname}", type: :feature do
  let (:uri) {"https://#{username}:#{password}@#{hostname}"}
  it "loads the front page" do
    visit uri
    expect(page).to have_content("Emory Theses and Dissertations")
  end
end
