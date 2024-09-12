# Generated via
#  `rails generate hyrax:work Etd`
module Hyrax
  class EtdForm < Hyrax::Forms::WorkForm
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
    self.terms += [:embargo_type]
    self.terms += [:files_embargoed]
    self.terms += [:abstract_embargoed]
    self.terms += [:toc_embargoed]

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
  end
end
