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
  def add_data(new_data)
    json_data = data || {}.to_json
    existing_data = JSON.parse(json_data)
    return existing_data unless new_data

    new_data = add_no_embargoes(new_data)
    existing_data = remove_stale_embargo_data(existing_data, new_data)
    new_data = keep_last_completed_step(existing_data, new_data)

    new_data = keep_school_has_changed(existing_data, new_data)
    resulting_data = existing_data.merge(new_data)
    self.data = resulting_data.to_json
    resulting_data
  end

  # currently the EtdForm uses the boolean param "no_embargoes", so we need to send or remove it (seems a good candidate for refactoring in EtdForm)

  def add_no_embargoes(new_data)
    resulting_data = new_data[:embargo_length] == NO_EMBARGO ? new_data.merge("no_embargoes" => "1") : nil

    resulting_data.nil? ? new_data : resulting_data
  end

  # Remove embargo_type, if new_data[:embargo_length] == NO_EMBARGO
  # Remove no_embargoes if new_data[:embargo_length] != NO_EMBARGO

  def remove_stale_embargo_data(existing_data, new_data)
    existing_data.delete('no_embargoes') if existing_data.keys.include?('no_embargoes') && new_data[:embargo_length] != NO_EMBARGO
    existing_data.delete('embargo_type') if new_data[:embargo_length] == NO_EMBARGO && existing_data.keys.include?('embargo_type')
    existing_data
  end

  def keep_last_completed_step(existing_data, new_data)
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
    new_data['etd_id'] = etd_id unless etd_id.blank?

    all_simple_fields.each do |field|
      new_value = etd.send field
      # Fedora returns arrays for these -- we aren't using arrays in the form
      # so this needs to use an array accessor
      new_data[field] = new_value[0] unless new_value.blank?
    end

    new_data['embargo_length'] = etd.embargo_length
    new_data['keyword'] = etd.keyword
    new_data['department'] = etd.department
    new_data['research_field'] = etd.research_field
    new_data['other_copyrights'] = etd.other_copyrights
    new_data['patents'] = etd.patents
    new_data['requires_permissions'] = etd.requires_permissions

    em_type = EmbargoTypeFromAttributes.new(etd.files_embargoed, etd.toc_embargoed, etd.abstract_embargoed)
    new_data['embargo_type'] = em_type.s

    # This code allows you to display and add chairs and members on the
    # edit form, but not remove them.
    etd_members = etd.committee_members.map { |member| JSON.parse(member.to_json) }.map { |values| { name: values["name"], affiliation: values["affiliation"] } }.uniq

    members = []
    etd_members.each do |member|
      if member[:affiliation] != 'Emory University'
        members.push(name: member[:name], affiliation: member[:affiliation], affiliation_type: 'Non-Emory')
      end
      if member[:affiliation] == 'Emory University'
        members.push(name: member[:name], affiliation: member[:affiliation], affiliation_type: 'Emory University')
      end
    end
    new_data['committee_members_attributes'] = members.uniq unless members.blank?

    etd_chairs = etd.committee_chair.map { |chair| JSON.parse(chair.to_json) }.map { |values| { name: values["name"], affiliation: values["affiliation"] } }.uniq
    chairs = []
    etd_chairs.each do |chair|
      if chair[:affiliation] != ['Emory University']
        chairs.push(name: chair[:name], affiliation: chair[:affiliation], affiliation_type: 'Non-Emory')
      end
      if chair[:affiliation] == ['Emory University']
        chairs.push(name: chair[:name], affiliation: chair[:affiliation], affiliation_type: 'Emory University')
      end
    end
    new_data['committee_chair_attributes'] = chairs.uniq unless chairs.blank?

    primary_file = file_for_refresh(etd.primary_file_fs.first)
    new_data['files'] = primary_file unless primary_file.blank?

    self.data = new_data.to_json
    save!
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
    }.to_json
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
