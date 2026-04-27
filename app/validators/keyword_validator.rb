class KeywordValidator < ActiveModel::Validator
  def validate(record)
    return unless current_tab?(record)
    ::Hyrax::EtdForm.keyword_terms.each do |field|
      record.errors.add(field, "#{field} is required") if record.data[field.to_s].blank? || record.data[field.to_s].first.blank?
    end
  end

  def current_tab?(record)
    record.data['currentTab'] == "Keywords"
  end
end
