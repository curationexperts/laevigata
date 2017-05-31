# services/research_field_service.rb
class ResearchFieldService < Hyrax::QaSelectService
  def initialize
    super('research_fields')
  end
end
