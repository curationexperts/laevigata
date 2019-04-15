# Generated via
#  `rails generate hyrax:work Etd`
module Hyrax
  class EtdForm < Hyrax::Forms::WorkForm
    include SingleValuedForm
    self.model_class = ::Etd
    # about me terms
    self.terms += [:graduation_date]
    self.terms += [:post_graduation_email]
    self.terms += [:resource_type]
    self.terms += [:school]
    self.terms += [:department]
    self.terms += [:subfield]
    self.terms += [:degree]
    self.terms += [:partnering_agency]
    self.terms += [:submitting_type]

    self.terms += [:committee_chair]
    self.terms += [:committee_members]

    self.terms -= [:rights]

    # about my etd terms
    self.terms += [:abstract]
    self.terms += [:keyword]
    self.terms += [:language]
    self.terms += [:research_field]
    self.terms += [:table_of_contents]
    self.terms += [:requires_permissions]
    self.terms += [:other_copyrights]
    self.terms += [:patents]
    # my embargo terms
    self.terms += [:embargo_length]
    self.terms += [:embargo_release_date]
    self.terms += [:embargo_type]
    self.terms += [:files_embargoed]
    self.terms += [:abstract_embargoed]
    self.terms += [:toc_embargoed]

    self.single_valued_fields = [:title, :creator, :post_graduation_email, :submitting_type, :graduation_date, :degree, :subfield, :department, :school, :language, :abstract, :table_of_contents]

    # methods for accessing new tab-determined sets of terms on new form tabs in new ui

    def self.about_me_terms
      [:creator, :graduation_date, :post_graduation_email, :school]
    end

    def self.my_program_terms
      [:department, :subfield, :partnering_agency, :degree, :submitting_type]
    end

    def self.my_etd_terms
      [:title, :language, :abstract, :table_of_contents]
    end

    def self.my_advisor_terms
      [:committee_members_attributes, :committee_chair_attributes]
    end

    def self.keyword_terms
      [:keyword, :research_field]
    end

    def about_me_fields
      [:creator, :graduation_date, :post_graduation_email]
    end

    def about_my_program_fields
      [:school, :department, :subfield, :partnering_agency, :degree, :submitting_type]
    end

    def about_my_etd_fields
      [:language, :abstract, :table_of_contents, :research_field]
    end

    def primary_pdf_name
      model.primary_pdf_file_name
    end

    # Initial state for the 'No Supplemental Files' checkbox.
    # Supplemental files aren't required for an ETD, but the
    # form validation requires the user to explicitly check the
    # 'No Supplemental Files' checkbox if they don't intend to
    # add any additional files.
    def no_supplemental_files
      model.persisted? && supplemental_files.blank?
    end

    def supplemental_files
      model.ordered_members.to_a.select(&:supplementary?)
    end

    # Initial state for the 'No Embargo' checkbox.
    def no_embargoes
      model.persisted? && !model.under_embargo?
    end

    def selected_embargo_type
      return '[:files_embargoed, :toc_embargoed, :abstract_embargoed]' if true_string?(model.abstract_embargoed)
      return '[:files_embargoed, :toc_embargoed]' if true_string?(model.toc_embargoed)
      return '[:files_embargoed]' if true_string?(model.files_embargoed)
    end

    # Both String and boolean 'true' should count as true.
    def true_string?(field)
      field == 'true' || field == true
    end

    # we need to pass a nil to Hyrax in order to remove a subfield
    # from an existing ETD, because the absence of the parameter won't
    def self.sanitize_params(form_params)
      form_params["subfield"] = nil unless form_params.include?("subfield")
      check_for_no_embargoes(form_params)
      super
    end

    # If no_embargoes is set, set all embargo fields to false
    def self.check_for_no_embargoes(params)
      return unless params["no_embargoes"] == "1"
      params["files_embargoed"] = "false"
      params["abstract_embargoed"] = "false"
      params["toc_embargoed"] = "false"
      params["toc_embargoed"] = "false"
      params["embargo_length"] = ""
    end

    # Select the correct affiliation type for committee member
    def cm_affiliation_type(value)
      value = Array(value).first
      if value.blank? || value == 'Emory University'
        cm_affiliation_options[0]
      else
        cm_affiliation_options[1]
      end
    end

    # Select the correct affiliation type for committee chair
    def cc_affiliation_type(value)
      value = Array(value).first
      if value.blank? || value == 'Emory University'
        cc_affiliation_options[0]
      else
        cc_affiliation_options[1]
      end
    end

    def cm_affiliation_options
      ["Emory Committee Member", "Non-Emory Committee Member"]
    end

    def cc_affiliation_options
      ["Emory Committee Chair", "Non-Emory Committee Chair"]
    end

    # In the view we have "fields_for :committee_members".
    # This method is needed to make fields_for behave as an
    # association and populate the form with the correct
    # committee member data.
    delegate :committee_members_attributes=, to: :model
    delegate :committee_chair_attributes=, to: :model

    # We need to call '.to_a' on committee_members to force it
    # to resolve.  Otherwise in the form, the fields don't
    # display the committee member's name and affiliation.
    # Instead they display something like:
    # '#<ActiveTriples::Relation:0x007fb564969c88>'
    def committee_members
      model.committee_members.build if model.committee_members.blank?
      model.committee_members.to_a
    end

    def committee_chair
      model.committee_chair.build if model.committee_chair.blank?
      model.committee_chair.to_a
    end

    def no_committee_members
      str_committee_members = model.committee_members.to_a.join(',')
      value = str_committee_members.count("a-zA-Z").zero?
      empty_committee_members = value
      model.persisted? && empty_committee_members
    end

    def self.build_permitted_params
      permitted = super
      permitted << { committee_members_attributes: [:id, { name: [] }, { affiliation: [] }, :affiliation_type, { netid: [] }, :_destroy] }
      permitted << { committee_chair_attributes: [:id, { name: [] }, { affiliation: [] }, :affiliation_type, { netid: [] }, :_destroy] }
      permitted
    end

    # If the student selects 'Emory Committee Chair' or
    # 'Emory Committee Member' for the 'affiliation_type' field,
    # then the 'affiliation' field becomes disabled in the form.
    # In that case, we need to fill in the 'affiliation' data
    # with 'Emory University', and we need to remove the
    # 'affiliation_type' field because that is not a valid field
    # for the CommitteeMember model.
    def self.model_attributes(form_params)
      attrs = super
      keys = ['committee_chair_attributes', 'committee_members_attributes']

      keys.each do |field_name|
        next if attrs[field_name].blank?
        attrs[field_name].each do |member_key, member_attrs|
          aff_type = attrs[field_name][member_key].delete 'affiliation_type'

          names = attrs[field_name][member_key]['name'] || []
          netids = attrs[field_name][member_key]['netid'] || []
          names_blank = names.all?(&:blank?)
          netids_blank = netids.all?(&:blank?)
          next if names_blank && netids_blank

          if member_attrs['affliation'].blank? && aff_type && aff_type.start_with?('Emory')
            attrs[field_name][member_key]['affiliation'] = ['Emory University']
          end
        end
      end

      attrs
    end
  end
end
