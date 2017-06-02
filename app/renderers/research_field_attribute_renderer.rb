class ResearchFieldAttributeRenderer < Hyrax::Renderers::AttributeRenderer
  def attribute_value_to_html(value)
    research_field_label = ResearchFieldService.new.label(value)
    # Adapted from Hyrax's AttributeRenderer
    if microdata_value_attributes(field).present?
      "<span#{html_attributes(microdata_value_attributes(field))}>#{li_value(research_field_label)}</span>"
    else
      li_value(research_field_label)
    end
  end
end
