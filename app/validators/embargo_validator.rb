class EmbargoValidator < ActiveModel::Validator
  def validate(record)
    return unless record.current_tab == "Embargo"
    # TODO: the embargo form will send 'no' values by default,
    # but this tab hasn't been built to conform to the wireframes yet.
    # when it is this validator will check for actual values.
    # ::Hyrax::EtdForm.embargo_terms.each do |field|
    #   record.errors.add(field, "#{field} is required") if parsed_data(record)[field.to_s].blank?
    # end
  end
end
