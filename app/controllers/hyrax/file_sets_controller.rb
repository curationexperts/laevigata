module Hyrax
  class FileSetsController < ApplicationController
    include Hyrax::FileSetsControllerBehavior
    self.show_presenter = EtdFileSetPresenter
  end
end
