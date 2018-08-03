class Ability
  include Hydra::Ability
  include Hyrax::Ability
  self.ability_logic += [:everyone_can_create_curation_concerns, :ipe_permissions]

  # Define any customized permissions here.
  def custom_permissions
    can [:read, :edit], String if can_review_submissions?
    return unless admin?
    can [:create, :show, :add_user, :remove_user, :index, :edit, :update, :destroy], Role
    can [:destroy], ActiveFedora::Base
    can [:read], Schools::School
  end

  def test_download(id)
    super || can_review_submissions?
  end

  def ipe_permissions
    can :create, InProgressEtd if registered_user?
    can :update, InProgressEtd, user_ppid: current_user.ppid

    # A user who has permission to edit the corresponding Etd should be able to edit the InProgressEtd. (e.g. admin users, proxy permissions, etc)
    can :update, InProgressEtd do |ipe|
      begin
        unless ipe.etd_id.blank?
          etd_doc = SolrDocument.find ipe.etd_id
          can? :edit, etd_doc
        end
      rescue Blacklight::Exceptions::RecordNotFound
        false
      end
    end
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
