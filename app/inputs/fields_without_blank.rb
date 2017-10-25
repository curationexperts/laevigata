module FieldsWithoutBlank

  # This overrides the 'collection' method from MultiValueInput in hydra-editor gem.
  # When you render a multi_value field on the form, hydra-editor helpfully adds an extra blank field.  But that blank field interferes with our form validation for required fields (because the blank field will be marked as required too).
  # So, for example, we require the 'keyword' field, but the user only needs to give one keyword.  If another (blank) keyword field is rendered on the form, then the form validation fails because it thinks that 2 keywords are required.  This problem appears when the user edits an existing ETD where they have already provided a keyword, but then the extra 'required' blank field shows up on the form and causes the form validation to fail.
  # So, we override this method to only add the extra blank value if the field doesn't have a value yet.
  def collection
    @collection ||= begin
                      val = object[attribute_name]
                      col = val.respond_to?(:to_ary) ? val.to_ary : val
                      col.reject { |value| value.to_s.strip.blank? }
                      col = [''] if col.blank?
                      col
                    end
  end
end
