class MyProgramValidator < ActiveModel::Validator
  def validate(record)
    return unless current_tab?(record)
    ::Hyrax::EtdForm.my_program_terms.each do |field|
      record.errors.add(field, "#{field} is required") if parsed_data(record)[field.to_s].empty?
    end
  end

  def parsed_data(record)
    JSON.parse(record.data)
  end

  def current_tab?(record)
    parsed_data(record)['currentTab'] == "My Program"
  end
end
