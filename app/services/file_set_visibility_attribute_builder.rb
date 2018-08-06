class FileSetVisibilityAttributeBuilder
  attr_accessor :work

  def initialize(work:)
    self.work = work
  end

  def build
    attributes = {}

    if work.files_embargoed
      attributes[:visibility] =
        Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO
      attributes[:visibility_during_embargo] =
        Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
      attributes[:embargo_release_date] = work.embargo_release_date.to_s
    else
      attributes[:visibility] =
        Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    end

    attributes
  end
end
