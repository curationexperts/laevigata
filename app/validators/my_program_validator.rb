class MyProgramValidator < ActiveModel::Validator
  def validate(record)
    return unless record.current_tab == "My Program"
    fields_to_validate = ::Hyrax::EtdForm.my_program_terms - [:partnering_agency]
    fields_to_validate.each do |field|
      next if field == :subfield # Subfields are not currently required
      record.errors.add(field, "#{field} is required") if record.data[field.to_s].blank?
    end
  end
end
