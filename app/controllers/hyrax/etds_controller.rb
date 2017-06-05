# Generated via
#  `rails generate hyrax:work Etd`

module Hyrax
  class EtdsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = Etd
    self.show_presenter = EtdPresenter

    def create
      # TODO: make this a case statement for each tab
      if params.fetch('about_me', false) == "true"
        @etd_about_me = params.fetch('etd')
        render json: @etd_about_me, status: 200
      else
        super
      end
    end
  end
end
