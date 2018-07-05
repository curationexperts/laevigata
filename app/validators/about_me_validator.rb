class AboutMeValidator < ActiveModel::Validator
  def validate(record)
    return unless current_tab?(record)
    ::Hyrax::EtdForm.about_me_terms.each do |field|
      record.errors.add(field, "#{field} is required") if parsed_data(record)[field.to_s].blank?
    end
  # TODO: confirm this rescue is not too general
  rescue NoMethodError
    missing_fields(record)
  end

  def parsed_data(record)
    JSON.parse(record.data)
  end

  def current_tab?(record)
    parsed_data(record)['currentTab'] == "About Me"
  end

  # a user can submit a tab without having selected certain fields, graduation_date and school in this case, and the keys will not be
  # present in the record's data. Since this is effectively the same as if they had not entered information, the fields are added to the errors.
  def missing_fields(record)
    record.errors.add("graduation_date", "graduation_date is required") unless parsed_data(record).keys.include?("graduation_date")

    record.errors.add("school", "school is required") unless parsed_data(record).keys.include?("school")
  end
end
