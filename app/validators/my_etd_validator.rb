class MyEtdValidator < ActiveModel::Validator
  def validate(record)
    return unless record.current_tab == "My Etd"
    ::Hyrax::EtdForm.my_etd_terms.each do |field|
      record.errors.add(field, "#{field} is required") if record.data[field.to_s].blank?
    end
  end
end
