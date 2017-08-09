class AddFileTypeToUploadedFile < ActiveRecord::Migration[5.0]
  def change
    add_column :uploaded_files, :file_type, :string
  end
end
