module HyraxHelper
  include ::BlacklightHelper
  include Hyrax::BlacklightOverride
  include Hyrax::HyraxHelperBehavior

  ##
  # override behavior from `Hyrax::AbilityHelper`
  def visibility_options(variant)
    options = [
      Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
      VisibilityTranslator::FILES_EMBARGOED,
      VisibilityTranslator::TOC_EMBARGOED,
      VisibilityTranslator::ALL_EMBARGOED,
      Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
    ]

    case variant
    when :restrict
      options.delete_at(0)
      options.reverse!
    when :loosen
      options = [Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC]
    end

    options.map { |value| [visibility_text(value), value] }
  end

  def visibility_badge(value)
    EtdPermissionBadge.new(value).render
  end
end
