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
    self.terms += [:research_field]
    self.terms += [:title]
    self.terms += [:language]
    self.terms += [:abstract]
    self.terms += [:table_of_contents]
    self.terms += [:description]
    self.terms += [:secondary_file_type]
    self.terms += [:creator]
    # placeholder about my program fields
    self.terms += [:committee_chair]
    self.terms += [:committee_members]
    # removing these for About me demo
    self.terms += [:rights_statement]
    self.terms += [:keyword]
    self.single_valued_fields = [:title, :creator, :submitting_type, :graduation_date, :degree, :subfield, :department,
                                 :school, :language, :abstract, :table_of_contents, :rights_statement, :description, :file_type]

    def about_me_fields
      [:creator, :graduation_date, :post_graduation_email]
    end

    def about_my_program_fields
      [:school, :department, :subfield, :research_field, :degree, :submitting_type, :committee_chair, :committee_members, :partnering_agency]
    end

    def about_my_etd_fields
      [:description, :table_of_contents, :keyword]
    end

    def supplemental_files_fields
      [:creator, :abstract, :secondary_file_type]
    end
  end
end
