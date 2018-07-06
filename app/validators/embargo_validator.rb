class EmbargoValidator < ActiveModel::Validator
  def validate(record)
    return unless current_tab?(record)
    # TODO: the embargo form will send 'no' values by default,
    # but this tab hasn't been built to conform to the wireframes yet.
    # when it is this validator will check for actual values.
    # ::Hyrax::EtdForm.embargo_terms.each do |field|
    #   record.errors.add(field, "#{field} is required") if parsed_data(record)[field.to_s].blank?
    # end
  end

  def parsed_data(record)
    return {} unless record.data
    JSON.parse(record.data)
  end

  def current_tab?(record)
    parsed_data(record)['currentTab'] == "Embargo"
  end
end
