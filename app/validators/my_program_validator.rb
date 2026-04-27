class MyProgramValidator < ActiveModel::Validator
  def validate(record)
    return unless current_tab?(record)
    fields_to_validate = ::Hyrax::EtdForm.my_program_terms - [:partnering_agency]
    fields_to_validate.each do |field|
      # TODO: confirm whether subfields are never required by Emory
      next if field == :subfield
      record.errors.add(field, "#{field} is required") if record.data[field.to_s].blank?
    end
  end

  def current_tab?(record)
    record.data['currentTab'] == "My Program"
  end
end
