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
    # placeholder about my program fields
    self.terms += [:committee_chair]
    self.terms += [:committee_members]
    # removing these for About me demo
    self.terms -= [:rights]
    self.terms -= [:keyword]
    self.single_valued_fields = [:title, :creator, :submitting_type, :graduation_date, :degree, :subfield, :department, :school]

    def about_me_fields
      [:creator, :graduation_date, :post_graduation_email]
    end

    def about_my_program_fields
      [:school, :department, :subfield, :partnering_agency, :research_field, :degree, :submitting_type, :committee_chair, :committee_members]
    end
  end
end
