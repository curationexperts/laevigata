# frozen_string_literal: true

module ApplicationHelper
  def formatted_date(time:)
    I18n.l(time.in_time_zone('Eastern Time (US & Canada)'), format: '%D %I:%M %p')
  end
end
