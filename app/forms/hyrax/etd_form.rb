# Generated via
#  `rails generate hyrax:work Etd`
module Hyrax
  class EtdForm < Hyrax::Forms::WorkForm
    include SingleValuedForm
    self.model_class = ::Etd
    # about me terms
    self.terms += [:graduation_date]
    self.terms += [:post_graduation_email]
    self.terms += [:school]
    self.terms += [:department]
    self.terms += [:subfield]
    self.terms += [:degree]
    self.terms += [:partnering_agency]
    self.terms += [:submitting_type]

    self.terms += [:committee_chair_attributes]
    self.terms += [:committee_members_attributes]

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
    self.terms += [:embargo_type]
    self.terms += [:files_embargoed]
    self.terms += [:abstract_embargoed]
    self.terms += [:toc_embargoed]

    self.single_valued_fields = [:title, :creator, :post_graduation_email, :submitting_type, :degree, :subfield, :department, :school, :language, :abstract, :table_of_contents]

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

    def primary_pdf_name
      model.primary_pdf_file_name
    end

    def supplemental_files
      model.ordered_members.to_a.select(&:supplementary?)
    end

    # we need to pass a nil to Hyrax in order to remove a subfield
    # from an existing ETD, because the absence of the parameter won't
    def self.sanitize_params(form_params)
      form_params["subfield"] = nil unless form_params.include?("subfield")
      super
    end

    # The JavaScript UI passes committe_chair and committee_member as nested arrays
    # This method is needed to populate the model with the correct nested committee attributes.
    def self.build_permitted_params
      permitted = super
      permitted << { committee_members_attributes: [:id, { name: [] }, { affiliation: [] }, :_destroy] }
      permitted << { committee_chair_attributes: [:id, { name: [] }, { affiliation: [] }, :_destroy] }
      permitted
    end
  end
end
