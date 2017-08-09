module TinyMce
  # A method to find and fill in fields for TinyMCE form elements.
  def tinymce_fill_in(id, val)
    # use 'sleep until' if you need wait until the TinyMCE editor instance is ready. This is required for cases
    # where the editor is loaded via XHR.
    # sleep 0.5 until
    page.evaluate_script("tinyMCE.get('#{id}') !== null")

    js = "tinyMCE.get('#{id}').setContent('#{val}')"
    page.execute_script(js)
  end
end

RSpec.configure do |config|
  config.include TinyMce, type: :feature
end
