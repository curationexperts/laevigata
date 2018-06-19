class ControlledSelectInput < SimpleForm::Inputs::CollectionSelectInput
  def input(wrapper_options = nil)
    existing_values = Array(object.send(attribute_name))

    return super if existing_values.empty?

    if existing_values.length > 1
      logger.warn("Editing a work with multiple values in #{attribute_name}, " \
                  'but using a single valued form field. Values were: ' \
                  "#{existing_values}")
    end

    @collection, wrapper_options =
      options[:item_helper]
        &.call(existing_values.first, 1, collection, wrapper_options)

    super
  end
end
