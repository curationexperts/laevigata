# Generated via
#  `rails generate hyrax:work Etd`
module Hyrax
  class EtdForm < Hyrax::Forms::WorkForm
    include SingleValuedForm
    self.model_class = ::Etd
    self.terms += [:resource_type]
    self.terms += [:department]
    self.terms += [:school]
    self.terms += [:degree]
    self.terms += [:partnering_agency]
    self.terms += [:submitting_type]
    self.single_valued_fields = [:title, :creator, :submitting_type]
  end
end
