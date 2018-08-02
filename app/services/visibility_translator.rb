##
# Determines visibily for a given Etd.
#
# Etd visibility is extended from `Hyrax` and `Hydra::AccessControls` to
# include three additional visibility levels:
#
#   - `VisibilityTranslator::FILES_EMBARGOED`: indicates that the work is
#     under embargo, but that it is discoverable (not `restricted`/private).
#     FileSets that are members of the work should be under a parallel embargo,
#     making tthem private until the embargo end date.
#   - `VisibilityTranslator::TOC_EMBARGOED`: indicates that the work is
#     under embargo, as described above, and that the table of contents should
#     be suppressed for the duration of the embargo.
#   - `VisibilityTranslator::ALL_EMBARGOED`: indicates that the work is
#     under embargo, as described above, and that the table of contents *and*
#     abstract should be suppressed for the duration of the embargo.
#
# @see Hydra::AccessControls::Visibility
class VisibilityTranslator
  ALL_EMBARGOED   = 'embargo; all'.freeze
  FILES_EMBARGOED = 'embargo; file'.freeze
  TOC_EMBARGOED   = 'embargo; toc + file'.freeze
  OPEN            = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC

  attr_accessor :obj

  def initialize(obj:)
    self.obj = obj
  end

  def self.visibility(obj:)
    new(obj: obj).visibility
  end

  def visibility
    return proxy.visibility unless obj.under_embargo?
    return ALL_EMBARGOED    if     obj.abstract_embargoed
    return TOC_EMBARGOED    if     obj.toc_embargoed

    FILES_EMBARGOED
  end

  def visibility=(value)
    case value
    when FILES_EMBARGOED
      raise(InvalidVisibilityError.new('Invalid embargo visibility level:', value, obj)) unless
        obj.under_embargo?

      obj.files_embargoed    = true
      obj.toc_embargoed      = false
      obj.abstract_embargoed = false
      proxy.visibility       = OPEN
    when TOC_EMBARGOED
      raise(InvalidVisibilityError.new('Invalid embargo visibility level:', value, obj)) unless
        obj.under_embargo?

      obj.files_embargoed    = true
      obj.toc_embargoed      = true
      obj.abstract_embargoed = false
      proxy.visibility       = OPEN
    when ALL_EMBARGOED
      raise(InvalidVisibilityError.new('Invalid embargo visibility level:', value, obj)) unless
        obj.under_embargo?

      obj.files_embargoed    = true
      obj.toc_embargoed      = true
      obj.abstract_embargoed = true
      proxy.visibility       = OPEN
    else
      proxy.visibility = value
    end
  end

  def proxy
    VisibilityProxy.new(obj)
  end

  class InvalidVisibilityError < ArgumentError
    def initialize(msg = 'Invalid visibility level:', level = nil, obj = nil)
      @level = level
      @obj   = obj
      @msg   = msg + " #{level}\nNo embargo is set on #{obj ? obj.id : 'the object'}."
    end

    def message
      @msg
    end
  end

  ##
  # Determines the value of the default `#visibility` method as implemented in
  # `Hydra::AccessControls::Visibility` for the provided `source`. Since we
  # expect this method to be overridden in `pcdm_object`s passed to
  # `VisibilityTranslator`, we need a proxy object to ensure we can access the
  # original implementation.
  #
  # @example
  #   my_model = ModelWithCustomVisibility.new
  #   my_model.visibility # => 'some custom value`
  #   VisibilityTranslator::VisibilityProxy.new(my_model).visibility # => 'open'
  #
  # @see Hydra::AccessControls::Visibility
  class VisibilityProxy
    extend Forwardable
    include Hydra::AccessControls::Visibility

    def_delegator :@original, :read_groups
    def_delegator :@original, :set_read_groups

    def initialize(original)
      @original = original
    end
  end
end
