##
# Determines visibily for a given FileSet
#
# When users of a FileSet try to copy visibility from a Work, they may try to
# copy custom visibilities, which the FileSet does not support.
#
# This translator supports the visibility extensions in `VisibilityTranslator`
# are within `FileSet`. It maps all of the extended visibilities to
# `restricted`, ensuring FileSets for embargoed/restricted works are kept
# private.
class FileSetVisibilityTranslator < VisibilityTranslator
  RESTRICTED_TEXT   = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
  RESTRICTED_VALUES = [FILES_EMBARGOED, TOC_EMBARGOED, ALL_EMBARGOED].freeze

  delegate :visibility, to: :proxy

  ##
  # @param  [String] value
  # @return [String]
  def visibility=(value)
    value = RESTRICTED_TEXT if RESTRICTED_VALUES.include? value

    proxy.visibility = value
  end
end
