class MyAdvisorValidator < ActiveModel::Validator
  def validate(record)
    return unless current_tab?(record)
    ::Hyrax::EtdForm.my_advisor_terms.each do |field|
      next if field == :committee_members_attributes
      record.errors.add(field, "#{field} is required") if parsed_data(record)[field.to_s].blank?
    end
  end

  def parsed_data(record)
    return {} unless record.data
    JSON.parse(record.data)
  end

  def current_tab?(record)
    parsed_data(record)['currentTab'] == "My Advisor"
  end
end
