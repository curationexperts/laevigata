class Ability
  include Hydra::Ability
  include Hyrax::Ability
  self.ability_logic += [:everyone_can_create_curation_concerns]

  # Define any customized permissions here.
  def custom_permissions
    return unless admin?
    can [:create, :show, :add_user, :remove_user, :index, :edit, :update, :destroy], Role
    can [:destroy], ActiveFedora::Base
  end

  ##
  # @note We always display the share button for every user. Rather than
  #   expressing this through the complex states of AdminSets and user
  #   permissions, we can just always return true in this presenter.
  #
  # @return [Boolean]
  def display_share_button?
    true
  end
end
