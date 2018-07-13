# frozen_string_literal: true

module EtdFormHelper
  def summarize_committee_member(label, attrs_hash)
    content_tag :p do
      content_tag(:b, label) +
        ": #{attrs_hash['name'].first} (#{attrs_hash['affiliation'].first})"
    end
  end
end
