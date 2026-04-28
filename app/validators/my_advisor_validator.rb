class MyAdvisorValidator < ActiveModel::Validator
  def validate(record)
    return unless record.current_tab == "My Advisor"
    ::Hyrax::EtdForm.my_advisor_terms.each do |field|
      next if field == :committee_members_attributes
      record.errors.add(field, "#{field} is required") if record.data[field.to_s].blank?
    end
  end
end
