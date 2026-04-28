class KeywordValidator < ActiveModel::Validator
  def validate(record)
    return unless record.current_tab == "Keywords"
    ::Hyrax::EtdForm.keyword_terms.each do |field|
      record.errors.add(field, "#{field} is required") if record.data[field.to_s].blank? || record.data[field.to_s].first.blank?
    end
  end
end
