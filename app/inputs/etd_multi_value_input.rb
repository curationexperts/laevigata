class EtdMultiValueInput < MultiValueInput
  include FieldsWithoutBlank

  # There is code in hyrax and/or hydra-editor (especially in the javascript) that is expecting the rendered divs to have the class 'multi_value'.
  def input_type
    'multi_value'.freeze
  end
end
