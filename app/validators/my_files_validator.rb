class MyFilesValidator < ActiveModel::Validator
  def validate(record)
    return unless current_tab?(record)
    record.errors.add('files', "A thesis or dissertation file is required") if parsed_data(record)['files'].nil?

    record.errors.add('supplementalFiles', "A title, description and file type are required for each Supplemental File.") if file_without_metadata(record)
  end

  def parsed_data(record)
    return {} unless record.data
    JSON.parse(record.data)
  end

  def current_tab?(record)
    parsed_data(record)['currentTab'] == "My Files"
  end

  def file_without_metadata(record)
    return false if parsed_data(record)['supplemental_files'].nil?
    return true if parsed_data(record)['supplemental_file_metadata'].nil?

    meta_missing = false
    parsed_data(record)['supplemental_file_metadata'].each do |sf|
      meta_missing = sf[1]['title'].blank? || sf[1]['description'].blank? || sf[1]['file_type'].blank? ? true : false
    end
    meta_missing
  end
end
