class MyEtdValidator < ActiveModel::Validator
  def validate(record)
    return unless current_tab?(record)
    ::Hyrax::EtdForm.my_etd_terms.each do |field|
      record.errors.add(field, "#{field} is required") if record.data[field.to_s].blank?
    end
  end

  def current_tab?(record)
    record.data['currentTab'] == "My Etd"
  end
end
