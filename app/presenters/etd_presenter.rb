class EtdPresenter < Hyrax::WorkShowPresenter
  delegate :abstract,
           :abstract_embargoed,
           :committee_chair_name,
           :committee_members_names,
           :degree,
           :department,
           :embargo_length,
           :files_embargoed,
           :graduation_date,
           :language,
           :school,
           :partnering_agency,
           :research_field,
           :rights_statement,
           :table_of_contents,
           :toc_embargoed,
           :requires_permissions,
           :other_copyrights,
           :patents,
           :under_embargo?,
           to: :solr_document

  # we want to override the permission_badge method in the FileSetPresenter class, because we handle embargos differently than Hyrax does.
  # Therefore we create an EtdFileSetPresenter that overwrites the permission_badge method,
  # and ensure the views get it by setting it as the file_presenter_class in the EtdMemberPresenterFactory, and creating an Etd member factory here.

  def subfield
    return unless solr_document.subfield
    id = solr_document.subfield.first
    school = Schools::School.new(solr_document.school.first)
    dept = Schools::Department.new(school, solr_document.department.first)

    return unless dept.service
    Schools::Subfield.new(school, dept, id).label
  end

  def member_presenter_factory
    Hyrax::EtdMemberPresenterFactory.new(solr_document, current_ability, request)
  end

  ##
  # Override `PresentsAttributes` to Use the custom `EtdPermissionBadge` class,
  # adding view support for custom Etd visibilities (embargo levels).
  #
  # @return [Class]
  def permission_badge_class
    EtdPermissionBadge
  end

  # Given an ARK in the identifier field, return an Emory permanent_url
  def permanent_url
    return nil unless identifier && identifier.first && identifier.first.match(/^ark/)
    "http://pid.emory.edu/#{identifier.first}"
  end

  # Return the post_graduation_email
  # NOTE: The field is defined as multivalued, but the application only stores a single value
  def post_graduation_email
    solr_document.to_h.dig('post_graduation_email_tesim', 0)
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

  def degree_awarded
    return "graduation pending" unless solr_document.degree_awarded
    solr_document.degree_awarded.to_date.strftime("%d %B %Y")
  end

  def proquest_submission_date
    return unless solr_document.proquest_submission_date
    solr_document.proquest_submission_date.first.to_date.strftime("%d %B %Y")
  end

  def submitting_type
    return "ETD" unless solr_document.submitting_type
    solr_document.submitting_type.first
  end

  # School-dependent label for departments
  # @return 'Department' unless school==nursing, which uses 'Specialty' instead
  def department_or_specialty
    school&.first&.match?(/Nursing|Woodruff/i) ? 'Specialty' : 'Department'
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
    return "This abstract is under embargo until #{formatted_embargo_release_date}" if under_embargo? && abstract_embargoed
    abstract.first
  end

  def abstract_for_admin
    admin_return_message = ""
    if under_embargo? && abstract_embargoed
      admin_return_message +=
        if solr_document.degree_awarded
          "[Abstract embargoed until #{formatted_embargo_release_date}] "
        elsif embargo_length
          "[Abstract embargoed until #{embargo_length} post-graduation] "
        else
          "[Abstract embargoed until post-graduation] "
        end
    end

    if under_embargo? && abstract_embargoed && degree_awarded
    elsif under_embargo? && abstract_embargoed
    end
    admin_return_message + abstract.first
  end

  def toc_with_embargo_check
    return "No table of contents is available." unless table_of_contents && table_of_contents.first
    return toc_for_admin if current_ability.admin?
    return toc_for_admin if current_ability_is_depositor?
    return toc_for_admin if current_ability_is_approver?
    return "This table of contents is under embargo until #{formatted_embargo_release_date}" if under_embargo? && toc_embargoed
    table_of_contents.first
  end

  def files_embargo_check
    return nil unless under_embargo? && files_embargoed
    return nil if current_ability.admin?
    return nil if current_ability_is_depositor?
    return nil if current_ability_is_approver?
    "File download under embargo until #{formatted_embargo_release_date}"
  end

  def toc_for_admin
    admin_return_message = ""
    if under_embargo? && toc_embargoed
      admin_return_message +=
        if embargo_length && solr_document.degree_awarded.blank?
          "[Table of contents embargoed until #{embargo_length} post-graduation] "
        elsif embargo_release_date
          "[Table of contents embargoed until #{formatted_embargo_release_date}] "
        else
          "[Table of contents embargoed until post-graduation] "
        end
    end
    admin_return_message + table_of_contents.first
  end
end
