# Generated via
#  `rails generate hyrax:work Etd`
module Hyrax
  class EtdForm < Hyrax::Forms::WorkForm
    include SingleValuedForm
    self.model_class = ::Etd
    self.terms += [:resource_type]
    self.terms += [:school]
    self.terms += [:department]
    self.terms += [:subfield]
    self.terms += [:degree]
    self.terms += [:partnering_agency]
    self.terms += [:submitting_type]
    self.terms += [:research_field]
    self.single_valued_fields = [:title, :creator, :submitting_type, :degree, :subfield, :department, :school]
  end
end
