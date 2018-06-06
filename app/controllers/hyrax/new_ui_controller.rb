require 'input_sanitizer'

module Hyrax
  class NewUiController < ApplicationController
    def new
      render :new, status: 200
    end
  end
end
