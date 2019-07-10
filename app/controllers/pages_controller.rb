# frozen_string_literal: true

class PagesController < ApplicationController
  def error_404
    flash[:alert] = 'The page you are looking for does not exist.'
    render status: 404
  end
end
