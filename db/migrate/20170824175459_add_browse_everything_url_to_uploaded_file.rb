class AddBrowseEverythingUrlToUploadedFile < ActiveRecord::Migration[5.0]
  def change
    add_column :uploaded_files, :browse_everything_url, :string
  end
end
