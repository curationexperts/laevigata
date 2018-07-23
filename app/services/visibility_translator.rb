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

  attr_accessor :obj

  def initialize(obj:)
    self.obj = obj
  end

  def self.visibility(obj:)
    new(obj: obj).visibility
  end

  def visibility
    return VisibilityProxy.new(obj).visibility unless obj.under_embargo?
    return ALL_EMBARGOED                       if     obj.abstract_embargoed
    return TOC_EMBARGOED                       if     obj.toc_embargoed

    FILES_EMBARGOED
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

    def initialize(original)
      @original = original
    end
  end
end
