module EtdsUploadsControllerBehavior
  extend Hyrax::UploadsControllerBehavior
  # not sure this create will get called
  def create
    # byebug
    @upload.attributes = { file: file,
                           user: current_user }
    @upload.save!
  end

  def file
    uploaded_file = params.fetch("supplemental_files", "files")
    uploaded_file.first
  end
end
