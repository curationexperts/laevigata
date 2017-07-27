# Generated via
#  `rails generate hyrax:work Etd`
module Hyrax
  class EtdForm < Hyrax::Forms::WorkForm
    include SingleValuedForm
    self.model_class = ::Etd
    # placeholder about me terms
    self.terms += [:graduation_date]
    self.terms += [:post_graduation_email]
    self.terms += [:resource_type]
    self.terms += [:school]
    self.terms += [:department]
    self.terms += [:subfield]
    self.terms += [:degree]
    self.terms += [:partnering_agency]
    self.terms += [:submitting_type]
    # placeholder about my program fields
    self.terms += [:committee_chair]
    self.terms += [:committee_members]
    # removing these for About me demo
    self.terms -= [:rights]

    # about my etd terms
    self.terms += [:abstract]
    self.terms += [:keyword]
    self.terms += [:language]
    self.terms += [:research_field]
    self.terms += [:table_of_contents]
    self.terms += [:copyright_question_one]
    self.terms += [:copyright_question_two]
    self.terms += [:copyright_question_three]
    self.terms += [:no_supplemental_files]
    # my embargo terms
    self.terms += [:embargo_length]
    self.terms += [:embargo_release_date]
    self.terms += [:files_embargoed]
    self.terms += [:abstract_embargoed]
    self.terms += [:toc_embargoed]

    self.single_valued_fields = [:title, :creator, :submitting_type, :graduation_date, :degree, :subfield, :department, :school, :language]

    def about_me_fields
      [:creator, :graduation_date, :post_graduation_email]
    end

    def about_my_program_fields
      [:school, :department, :subfield, :partnering_agency, :degree, :submitting_type, :committee_chair]
    end

    def about_my_etd_fields
      [:language, :abstract, :table_of_contents, :research_field]
    end
  end
end
