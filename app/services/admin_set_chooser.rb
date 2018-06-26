class AdminSetChooser
  # Determine what admin set an ETD should belong to,
  # based on what school and department it belongs to.
  #
  # @return [String] the name of an admin set
  def determine_admin_set(school, department, subfield)
    admin_set_determined_by_school = ["Laney Graduate School", "Candler School of Theology", "Emory College"]
    return school.first if admin_set_determined_by_school.include?(school.first) && valid_admin_sets.include?(school.first)
    return department.first if valid_admin_sets.include?(department.first)
    return subfield.first if valid_admin_sets.include?(subfield.first)
  end

  def valid_admin_sets
    @valid_admin_sets ||= YAML.safe_load(File.read(WorkflowSetup::DEFAULT_ADMIN_SETS_CONFIG)).keys
  end
end
