# frozen_string_literal: true

class SchoolsController < ApplicationController
  before_action :auth
  layout 'hyrax/dashboard'

  def index
    @school_terms = Schools::School.active_elements
  end

  def show
    @school = Schools::School.new(params[:id])
  end

  private

    def auth
      authorize! :read, Schools::School
    end
end
