# frozen_string_literal: true

module EtdFormHelper
  def summarize_committee_member(label, attrs_hash)
    content_tag :p do
      content_tag(:b, label) +
        ": #{attrs_hash['name'].first} (#{attrs_hash['affiliation'].first})"
    end
  end

  # If we're using the old UI, just use the regular path from Hyrax for editing Etd record.
  # If we're using the new UI, use the path for the InProgressEtdsController.
  def etd_edit_link(presenter)
    if Rails.application.config_for('new_ui').fetch('enabled', false)
      link_to 'Edit', main_app.new_in_progress_etd_path(etd_id: presenter.id), class: 'btn btn-default', data: { turbolinks: false }
    else
      link_to 'Edit', edit_polymorphic_path([main_app, presenter]), class: 'btn btn-default'
    end
  end
end
