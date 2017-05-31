module ApplicationHelper
  def research_field_label(options = {})
    research_field_service = ResearchFieldService.new
    options[:value].map { |field_code| html_escape(research_field_service.label(field_code)) }.to_sentence
  end

  def research_field_facet(field_code)
    ResearchFieldService.new.label(field_code)
  end
end
