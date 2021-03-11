class Ability
  include Hydra::Ability
  include Hyrax::Ability
  self.ability_logic += [:everyone_can_create_curation_concerns, :ipe_permissions]

  # Define any customized permissions here.
  def custom_permissions
    if can_review_submissions?
      can [:manage], String do |id|
        approver_for?(admin_set: ActiveFedora::Base.find(id)&.admin_set)
      end

      can [:manage], ActiveFedora::Base do |obj|
        approver_for?(admin_set: obj.admin_set)
      end
    end
    # At this point approvers can't update, edit, or manage Hydra::AccessControls::Embargo
    return unless admin?
    # Approvers don't hit this point in the code
    can [:create, :show, :add_user, :remove_user, :index, :edit, :update, :destroy], Role
    can [:destroy], ActiveFedora::Base
    can [:read], Schools::School
    can [:update], Hydra::AccessControls::Embargo
  end

  def test_download(id)
    super || can_review_submissions?
  end

  def curation_concerns_permissions
    alias_action :versions, to: :update
    alias_action :file_manager, to: :update

    return if admin?
    # At this point approvers can't update, edit, or manage Hydra::AccessControls::Embargo
    # current_user.ability.rules.map { |rule| rule if rule.subjects == [Hydra::AccessControls::Embargo] }.compact
    cannot [:update, :edit, :manage, :index], Hydra::AccessControls::Embargo
    cannot :manage, Hydra::AccessControls::Lease
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

  private

    def approver_for?(admin_set:)
      return false unless admin_set

      workflow = admin_set.active_workflow
      Hyrax::Workflow::PermissionQuery
        .scope_processing_workflow_roles_for_user_and_workflow(user:     @user,
                                                               workflow: workflow)
        .pluck(:role_id)
        .map { |id| Sipity::Role.find(id).name }
        .include?('approving')
    end
end
