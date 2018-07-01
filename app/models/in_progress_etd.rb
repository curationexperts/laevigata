class InProgressEtd < ApplicationRecord
  # custom validators check for presence of tab-determined set of fields based on presence of tab-identifying data
  validates_with AboutMeValidator
  validates_with MyProgramValidator
end
