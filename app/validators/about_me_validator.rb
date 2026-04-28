class AboutMeValidator < ActiveModel::Validator
  def validate(record)
    return unless record.current_tab == "About Me"
    ::Hyrax::EtdForm.about_me_terms.each do |field|
      record.errors.add(field, "#{field} is required") if record.data[field.to_s].blank?
    end
  end
end
