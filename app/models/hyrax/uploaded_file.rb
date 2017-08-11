module Hyrax
  # Store a file uploaded by a user. Eventually these files get
  # attached to FileSets and pushed into Fedora.
  class UploadedFile < ActiveRecord::Base
    before_create :scan_for_viruses
    self.table_name = 'uploaded_files'
    mount_uploader :file, UploadedFileUploader
    belongs_to :user, class_name: '::User'

    before_destroy :remove_file!

    private

      # Scan all newly uploaded files for viruses
      def scan_for_viruses
        path = file.path
        File.delete(path) if Clamby.virus?(path)
      end
  end
end
