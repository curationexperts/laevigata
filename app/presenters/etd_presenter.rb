class EtdPresenter < Hyrax::WorkShowPresenter
  delegate :abstract,
           :abstract_embargoed,
           :committee_chair_name,
           :committee_members_names,
           :degree,
           :department,
           :files_embargoed,
           :graduation_year,
           :language,
           :school,
           :subfield,
           :partnering_agency,
           :research_field,
           :rights_statement,
           :submitting_type,
           :table_of_contents,
           :toc_embargoed,
           to: :solr_document

  # Given an ARK in the identifier field, return an Emory permanent_url
  def permanent_url
    return nil unless identifier && identifier.first && identifier.first.match(/^ark/)
    "http://pid.emory.edu/#{identifier.first}"
  end

  def formatted_embargo_release_date
    Date.parse(embargo_release_date).strftime("%d %B %Y")
  end

  def current_user_roles
    workflow = AdminSet.where(title: admin_set).first.active_workflow
    Hyrax::Workflow::PermissionQuery.scope_processing_workflow_roles_for_user_and_workflow(
      user: current_ability.current_user,
      workflow: workflow
    ).pluck(:role_id).map { |r| Sipity::Role.where(id: r).first.name }
  end

  def current_ability_is_approver?
    roles = current_user_roles
    return true if roles.include? "approving"
    return true if roles.include? "reviewing"
    false
  end

  # TODO: check date of embargo release and make sure it hasn't passed already
  def abstract_with_embargo_check
    return "No abstract is available." unless abstract && abstract.first
    return abstract_for_admin if current_ability.admin?
    return abstract_for_admin if current_ability_is_approver?
    return "This abstract is under embargo until #{formatted_embargo_release_date}" if embargo_release_date && abstract_embargoed
    abstract.first
  end

  def abstract_for_admin
    admin_return_message = ""
    if embargo_release_date && abstract_embargoed
      admin_return_message += "[Abstract embargoed until #{formatted_embargo_release_date}] "
    end
    admin_return_message + abstract.first
  end

  def toc_with_embargo_check
    return "No table of contents is available." unless table_of_contents && table_of_contents.first
    return toc_for_admin if current_ability.admin?
    return toc_for_admin if current_ability_is_approver?
    return "This table of contents is under embargo until #{formatted_embargo_release_date}" if embargo_release_date && toc_embargoed
    table_of_contents.first
  end

  def files_embargo_check
    return nil unless embargo_release_date && files_embargoed
    return nil if current_ability.admin?
    return nil if current_ability_is_approver?
    "File download under embargo until #{formatted_embargo_release_date}"
  end

  def toc_for_admin
    admin_return_message = ""
    if embargo_release_date && toc_embargoed
      admin_return_message += "[Table of contents embargoed until #{formatted_embargo_release_date}] "
    end
    admin_return_message + table_of_contents.first
  end
end
