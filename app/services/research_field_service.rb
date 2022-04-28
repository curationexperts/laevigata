# services/research_field_service.rb
class ResearchFieldService < Hyrax::QaSelectService
  def initialize
    super('research_fields')
  end

  def select_all_ids
    authority.all.map { |e| [e[:id], e[:id]] }
  end

  def select_active_ids
    select_active_options.map { |_, id| [id, id] }
  end
end
