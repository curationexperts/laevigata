class MyFilesValidator < ActiveModel::Validator
  def validate(record)
    return unless current_tab?(record)
    record.errors.add('files', "A thesis or dissertation file is required") if parsed_data(record)['files'] == 'undefined'
  end

  def parsed_data(record)
    return {} unless record.data
    JSON.parse(record.data)
  end

  def current_tab?(record)
    parsed_data(record)['currentTab'] == "My Files"
  end
end
