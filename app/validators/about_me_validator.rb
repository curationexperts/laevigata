class AboutMeValidator < ActiveModel::Validator
  def validate(record)
    return unless current_tab?(record)
    ::Hyrax::EtdForm.about_me_terms.each do |field|
      record.errors.add(field, "#{field} is required") if record.data[field.to_s].blank?
    end
  end

  def current_tab?(record)
    record.data['currentTab'] == "About Me"
  end
end
