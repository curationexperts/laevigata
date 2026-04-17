class Ability
  include Hydra::Ability
  include Hyrax::Ability
  self.ability_logic += [:everyone_can_create_curation_concerns, :ipe_permissions]

  # Define any customized permissions here.
  def custom_permissions
    if can_review_submissions?
      can [:manage], String do |id|
        approver_for?(ActiveFedora::Base.find(id)&.admin_set)
      end

      can [:manage], ActiveFedora::Base do |obj|
        approver_for?(obj.admin_set)
      end
    end
    return unless admin?
    can [:create, :show, :add_user, :remove_user, :index, :edit, :update, :destroy], Role
    can [:destroy], ActiveFedora::Base
    can [:read], Schools::School
    can [:manage], RegistrarFeed
  end

  def test_download(id)
    super || can_review_submissions?
  end

  def curation_concerns_permissions
    alias_action :versions, to: :update
    alias_action :file_manager, to: :update

    return if admin?
    cannot [:update, :edit, :manage, :index], Hydra::AccessControls::Embargo
    cannot :index, Hydra::AccessControls::Lease
  end

  def ipe_permissions
    can :create, InProgressEtd if registered_user?
    can :update, InProgressEtd, user_ppid: current_user.ppid
    can :manage, InProgressEtd if admin?
    if can_review_submissions?
      can :manage, InProgressEtd do |ipe|
        approver_for?(ipe.admin_set)
      end
    end

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

  # Does the current user have the 'approving' role for a specific workflows?
  # @return [Boolean]
  def approver_for?(admin_set)
    PermissionChecker.user_can_approve_admin_set?(current_user, admin_set)
  end

  # Does the current user have the 'approving' role in any workflows?
  # @return [Boolean]
  def can_review_submissions?
    PermissionChecker.sipity_approver?(current_user)
  end
end
