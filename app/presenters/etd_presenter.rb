class EtdPresenter < Hyrax::WorkShowPresenter
  delegate :abstract,
           :abstract_embargoed,
           :committee_chair_name,
           :committee_members_names,
           :degree,
           :degree_awarded,
           :department,
           :embargo_length,
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
           :requires_permissions,
           :other_copyrights,
           :patents,
           to: :solr_document

  # we want to override the permission_badge method in the FileSetPresenter class, because we handle embargos differently than Hyrax does.
  # Therefore we create an EtdFileSetPresenter that overwrites the permission_badge method,
  # and ensure the views get it by setting it as the file_presenter_class in the EtdMemberPresenterFactory, and creating an Etd member factory here.

  def member_presenter_factory
    Hyrax::EtdMemberPresenterFactory.new(solr_document, current_ability, request)
  end

  # Given an ARK in the identifier field, return an Emory permanent_url
  def permanent_url
    return nil unless identifier && identifier.first && identifier.first.match(/^ark/)
    "http://pid.emory.edu/#{identifier.first}"
  end

  # Disabling .ttl, jsonld and nt entirely, because these methods expose embargoed content.
  # If we need it in the future, go back to using the version of this method
  # defined in Hyrax.
  def export_as_ttl
    'Not implemented at this time.'
  end

  def export_as_jsonld
    'Not implemented at this time.'
  end

  def export_as_json
    'Not implemented at this time.'
  end

  def export_as_nt
    'Not implemented at this time.'
  end

  def formatted_embargo_release_date
    embargo_release_date.strftime("%d %B %Y")
  end

  def current_user_roles
    # Note: AdminSets need an exact, non-tokenized solr query. A query like
    # AdminSet.where(title: admin_set) is too broad and might match the wrong AdminSet,
    # because there are AdminSets with similar names (e.g., Epidemiology and Global Epidemiology)
    workflow = AdminSet.where(title_sim: admin_set.first).first.active_workflow
    Hyrax::Workflow::PermissionQuery.scope_processing_workflow_roles_for_user_and_workflow(
      user: current_ability.current_user,
      workflow: workflow
    ).pluck(:role_id).map { |r| Sipity::Role.where(id: r).first.name }
  end

  def current_ability_is_approver?
    return false if current_ability.current_user.id.nil?
    roles = current_user_roles
    return true if roles.include? "approving"
    return true if roles.include? "reviewing"
    false
  end

  def current_ability_is_depositor?
    return false unless solr_document["depositor_ssim"] && solr_document["depositor_ssim"].first
    return true if current_ability.current_user.ppid == solr_document["depositor_ssim"].first
    false
  end

  # TODO: check date of embargo release and make sure it hasn't passed already
  def abstract_with_embargo_check
    return "No abstract is available." unless abstract && abstract.first
    return abstract_for_admin if current_ability.admin?
    return abstract_for_admin if current_ability_is_depositor?
    return abstract_for_admin if current_ability_is_approver?
    return "This abstract is under embargo until #{formatted_embargo_release_date}" if embargo_release_date && abstract_embargoed
    abstract.first
  end

  def abstract_for_admin
    admin_return_message = ""
    if embargo_release_date && abstract_embargoed
      admin_return_message +=
        if degree_awarded
          "[Abstract embargoed until #{formatted_embargo_release_date}] "
        elsif embargo_length
          "[Abstract embargoed until #{embargo_length.first} post-graduation] "
        else
          "[Abstract embargoed until post-graduation] "
        end
    end

    if embargo_release_date && abstract_embargoed && degree_awarded
    elsif embargo_release_date && abstract_embargoed
    end
    admin_return_message + abstract.first
  end

  def toc_with_embargo_check
    return "No table of contents is available." unless table_of_contents && table_of_contents.first
    return toc_for_admin if current_ability.admin?
    return toc_for_admin if current_ability_is_depositor?
    return toc_for_admin if current_ability_is_approver?
    return "This table of contents is under embargo until #{formatted_embargo_release_date}" if embargo_release_date && toc_embargoed
    table_of_contents.first
  end

  def files_embargo_check
    return nil unless embargo_release_date && files_embargoed
    return nil if current_ability.admin?
    return nil if current_ability_is_depositor?
    return nil if current_ability_is_approver?
    "File download under embargo until #{formatted_embargo_release_date}"
  end

  def toc_for_admin
    admin_return_message = ""
    if embargo_release_date && toc_embargoed
      admin_return_message +=
        if embargo_length && !degree_awarded
          "[Table of contents embargoed until #{embargo_length.first} post-graduation] "
        elsif embargo_release_date
          "[Table of contents embargoed until #{formatted_embargo_release_date}] "
        else
          "[Table of contents embargoed until post-graduation] "
        end
    end
    admin_return_message + table_of_contents.first
  end

  def requires_permissions_question
    return "Yes" if requires_permissions.to_s.include?("true")
    return "No" if requires_permissions.to_s.include?("false")
    "Unanswered"
  end

  def other_copyrights_question
    return "Yes" if other_copyrights.to_s.include?("true")
    return "No" if other_copyrights.to_s.include?("false")
    "Unanswered"
  end

  def patents_question
    return "Yes" if patents.to_s.include?("true")
    return "No" if patents.to_s.include?("false")
    "Unanswered"
  end
end
