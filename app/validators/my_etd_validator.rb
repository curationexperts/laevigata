class MyEtdValidator < ActiveModel::Validator
  def validate(record)
    return unless current_tab?(record)
    ::Hyrax::EtdForm.my_etd_terms.each do |field|
      record.errors.add(field, "#{field} is required") if parsed_data(record)[field.to_s].blank?
    end
  end

  def parsed_data(record)
    return {} unless record.data
    JSON.parse(record.data)
  end

  def current_tab?(record)
    parsed_data(record)['currentTab'] == "My Etd"
  end
end
