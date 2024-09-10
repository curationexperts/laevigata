# frozen_string_literal: true

# This class is used to represent an `Etd` record.
# It holds the data in a JSON data store for use by
# the Vue form.
#
# If the student fills in part of the form and saves,
# the partially-filled-in data will be saved in the
# `data` field.  If the student wants to continue
# editing their ETD later, this data will be used to
# populate the form with the data the student had
# previously saved.
#
# After the `Etd` record has been created in fedora
# (the student filled in the entire form and
# submitted it for approval), this class will still
# be used to represent the `Etd` in the Vue form, but
# its `data` field might need to be refreshed from
# the data on the `Etd` record that it represents.

class InProgressEtd < ApplicationRecord
  NO_EMBARGO = 'None - open access immediately'

  after_create :add_id_to_data_store

  # custom validators check for presence of tab-determined set of fields based on presence of tab-identifying data
  validates_with AboutMeValidator
  validates_with MyProgramValidator
  validates_with MyEtdValidator
  validates_with MyAdvisorValidator
  validates_with KeywordValidator
  validates_with EmbargoValidator
  validates_with MyFilesValidator

  # @param new_data [Hash, HashWithIndifferentAccess] New data to add to the existing data store.
  # @return [Hash] The resulting hash, with new data added to old data.
  # Note: new_data might only have a few fields in it.
  # We can't assume that new_data contains a full set
  # of metadata, so, for example, we can't assume that
  # the absence of a key means that a field should be
  # deleted.
  # This method has evolved and uses knowledge of
  # which metadata fields come from which tabs on
  # the edit form to delete or transform some of the
  # fields.  Time to refactor?  Instead of polluting
  # the back end code with knowledge about the form,
  # we could change the form to always submit all the
  # data from each tab, including blank fields.
  # Blank fields should be first-class data, just like
  # populated fields.
  def add_data(new_data)
    json_data = data || {}.to_json
    existing_data = JSON.parse(json_data)
    return existing_data unless new_data

    new_data = keep_last_completed_step(existing_data, new_data)
    new_data = keep_school_has_changed(existing_data, new_data)
    new_data = strip_blank_fields(new_data)
    remove_blank_members(new_data)
    remove_blank_supp_files(new_data)

    resulting_data = existing_data.merge(new_data)
    self.data = resulting_data.to_json
    resulting_data
  end

  # If we see the 'files' key in the new_data, then
  # we assume that we are submitting data from the
  # 'My Files' tab, so if the (optional) fields for
  # supplemental files aren't present, we can assume
  # the student deleted all the supplemental files
  # from the form, so we should also delete those
  # files from the cached data on the model.
  def remove_blank_supp_files(new_data)
    return unless new_data.key?('files')
    return unless new_data['supplemental_files'].blank?
    new_data['supplemental_files'] = nil
    new_data['supplemental_file_metadata'] = nil
  end

  # If we see the committee_chair_attributes key in
  # the new_data, then we assume that we are
  # submitting data from the 'My Advisor' tab, so
  # if (optional) committee members field is
  # missing from the keys, we can assume the student
  # deleted all the committee members off the form,
  # and then we should delete the members from the
  # cached data on the model.
  def remove_blank_members(new_data)
    return unless new_data.key?('committee_chair_attributes')
    return unless new_data['committee_members_attributes'].blank?
    new_data['committee_members_attributes'] = []
  end

  def strip_blank_fields(new_data)
    new_data.each do |key, value|
      next unless value.respond_to?(:reject)
      new_data[key] = value.reject { |v| v.blank? }
    end
    new_data
  end

  def keep_last_completed_step(existing_data, new_data)
    return new_data unless new_data[:currentStep]
    new_data[:currentStep] = existing_data['currentStep'] if existing_data.keys.include?('currentStep') && existing_data['currentStep'] >= new_data[:currentStep]
    new_data
  end

  def keep_school_has_changed(existing_data, new_data)
    return new_data unless etd_id.blank?
    if existing_data['school'].blank? || new_data[:school].blank?
      new_data[:schoolHasChanged] = false
      return new_data
    end

    new_data[:schoolHasChanged] = new_data[:school] != existing_data['school'] ? true : false
    new_data
  end

  # Store this record's ID for the javascript form to use.
  def add_id_to_data_store
    return unless id
    add_data('ipe_id' => id)
    save
  end

  # If this record is associated with an Etd record
  # that has already been persisted to fedora, we
  # need to refresh the JSON data store with the
  # latest data from the Etd.  (This record
  # may contain stale data if the Etd record was
  # updated outside the UI, e.g. a background job.)
  def refresh_from_etd!
    return if etd_id.blank?
    etd = Etd.find etd_id
    new_data = {}
    new_data['ipe_id'] = id unless id.blank?
    new_data['etd_id'] = etd_id

    all_simple_fields.each do |field|
      new_value = etd.send field
      # Fedora returns arrays for these -- we aren't using arrays in the form
      # so this needs to use an array accessor
      new_data[field] = new_value[0] unless new_value.blank?
    end

    # Single value fields or fields that need special handling
    new_data['degree_awarded'] = etd.degree_awarded # Needed by javascript
    new_data['embargo_length'] = etd.embargo_length
    new_data['keyword'] = etd.keyword
    new_data['department'] = etd.department
    new_data['research_field'] = etd.research_field
    new_data['other_copyrights'] = etd.other_copyrights
    new_data['patents'] = etd.patents
    new_data['requires_permissions'] = etd.requires_permissions
    new_data['partnering_agency'] = etd.partnering_agency
    new_data['graduation_date'] = etd.graduation_date
    new_data['embargo_type'] = etd.embargo_type

    members = etd.committee_members.map do |member|
      member.as_json.merge(affiliation_type: affiliation_type(member.affiliation.first))
    end
    new_data['committee_members_attributes'] = members.uniq

    chairs = etd.committee_chair.map do |chair|
      chair.as_json.merge(affiliation_type: affiliation_type(chair.affiliation.first))
    end
    new_data['committee_chair_attributes'] = chairs.uniq

    primary_file = file_for_refresh(etd.primary_file_fs.first)
    new_data['files'] = primary_file.to_json unless primary_file.blank?

    unless etd.supplemental_files_fs.blank?
      new_data['supplemental_files'], new_data['supplemental_file_metadata'] = supplemental_files_for_refresh(etd)
    end

    self.data = new_data.to_json
    save!
  end

  def affiliation_type(affilitation)
    return 'Non-Emory' if affilitation != 'Emory University'
    'Emory University'
  end

  # Information about the supplemental files that the JavaScript needs for the edit form.
  # @returns {Array} that contains 2 things: 'supplemental_files' (an array converted to JSON), and 'supplemental_file_metadata' (an array).
  # The 2 arrays are expected to keep the same order between them.
  # For example, the metadata in array index 0 of supplemental_files_metadata belongs to the file described in array index 0 of supplemental_files.
  def supplemental_files_for_refresh(etd)
    supp_files = []
    supp_files_metadata = []

    etd.supplemental_files_fs.each do |supp_file|
      supp_files << file_for_refresh(supp_file)
      supp_files_metadata << file_metadata_for_refresh(supp_file)
    end

    [supp_files.to_json, supp_files_metadata]
  end

  # Information about the file that the JavaScript needs for display and to render the 'Remove' button.
  def file_for_refresh(file_set)
    return if file_set.blank?
    {
      'id' => file_set.id,
      'name' => file_set.label,
      'size' => file_set.file_size.first,
      'deleteUrl' => Rails.application.class.routes.url_helpers.hyrax_file_set_path(file_set),
      'deleteType' => 'DELETE'
    }
  end

  # The metadata fields for the supplemental files on the ETD edit form.
  def file_metadata_for_refresh(file_set)
    return if file_set.blank?
    {
      'filename' => file_set.label,
      'title' => file_set.title,
      'description' => file_set.description,
      'file_type' => file_set.file_type
    }
  end

  # All the fields that this model needs to know,
  # except the fields for committee chairs and
  # members, which are nested fields.
  def all_simple_fields
    ::Hyrax::EtdForm.about_me_terms +
      ::Hyrax::EtdForm.my_program_terms +
      ::Hyrax::EtdForm.my_etd_terms +
      ::Hyrax::EtdForm.keyword_terms
  end
end
