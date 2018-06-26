class InProgressEtd < ApplicationRecord
  Hyrax::EtdForm.terms.each do |term|
    attr_accessor term
  end
end
