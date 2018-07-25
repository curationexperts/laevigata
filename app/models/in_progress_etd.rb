class InProgressEtd < ApplicationRecord
  after_create :add_id_to_data_store

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
    new_data = add_no_embargoes(new_data)
    existing_data = remove_stale_embargo_data(existing_data, new_data)
    existing_data = remove_stale_keyword_data(existing_data, new_data)

    resulting_data = existing_data.merge(new_data)
    self.data = resulting_data.to_json
    resulting_data
  end

  # currently the EtdForm uses the boolean param "no_embargoes", so we need to send or remove it (seems a good candidate for refactoring in EtdForm)

  def add_no_embargoes(new_data)
    resulting_data = new_data[:embargo_length] == 'None - open access immediately' ? new_data.merge("no_embargoes" => "1") : nil

    resulting_data.nil? ? new_data : resulting_data
  end

  # Remove embargo_type, if new_data[:embargo_length] == 'None - open access immediately'
  # Remove no_embargoes if new_data[:embargo_length] != 'None - open access immediately'

  def remove_stale_embargo_data(existing_data, new_data)
    existing_data.delete('no_embargoes') if existing_data.keys.include?('no_embargoes') && new_data[:embargo_length] != 'None - open access immediately'

    existing_data.delete('embargo_type') if new_data[:embargo_length] == 'None - open access immediately' && existing_data.keys.include?('embargo_type')
    existing_data
  end

  def remove_stale_keyword_data(existing_data, new_data)
    existing_data.delete('keyword') if existing_data.keys.include?('keyword') && new_data[:keyword].nil?
    existing_data
  end

  # Store this record's ID for the javascript form to use.
  def add_id_to_data_store
    return unless id
    add_data('ipe_id' => id)
    save
  end
end
