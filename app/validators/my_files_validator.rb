class MyFilesValidator < ActiveModel::Validator
  def validate(record)
    return unless record.current_tab == "My Files"
    record.errors.add('files', "A thesis or dissertation file is required") if record.data['files'].nil?

    record.errors.add('supplementalFiles', "A title, description and file type are required for each Supplemental File.") if file_without_metadata(record)
  end

  def file_without_metadata(record)
    return false if record.data['supplemental_files'].nil?
    return true if record.data['supplemental_file_metadata'].nil?

    meta_missing = false
    record.data['supplemental_file_metadata'].each do |sf|
      meta_missing = sf[1]['title'].blank? || sf[1]['description'].blank? || sf[1]['file_type'].blank? ? true : false
    end
    meta_missing
  end
end
