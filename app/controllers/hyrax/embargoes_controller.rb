# frozen_string_literal: true
module Hyrax
  class EmbargoesController < ApplicationController
    include Hyrax::EmbargoesControllerBehavior
    # Override edit method to check authorization
    def edit
      add_breadcrumb t(:'hyrax.controls.home'), root_path
      add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
      add_breadcrumb t(:'hyrax.embargoes.index.manage_embargoes'), hyrax.embargoes_path
      add_breadcrumb t(:'hyrax.embargoes.edit.embargo_update'), '#'
      authorize! :edit, Hydra::AccessControls::Embargo
    end
    with_themed_layout 'dashboard'
  end
end
