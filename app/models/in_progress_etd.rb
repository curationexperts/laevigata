class InProgressEtd < ApplicationRecord
  # custom validators check for presence of tab-determined set of fields based on presence of tab-identifying data
  validates_with AboutMeValidator
  validates_with MyProgramValidator
  validates_with MyEtdValidator
  validates_with MyAdvisorValidator
  validates_with KeywordValidator
  validates_with EmbargoValidator

  # @param new_data [Hash, HashWithIndifferentAccess] New data to add to the existing data store.
  # @return [Hash] The resulting hash, with new data added to old data.
  def add_data(new_data)
    json_data = data || {}.to_json
    existing_data = JSON.parse(json_data)
    return existing_data unless new_data

    resulting_data = existing_data.merge(new_data)
    self.data = resulting_data.to_json
    resulting_data
  end
end
