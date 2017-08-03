class AddTitleToUploadedFile < ActiveRecord::Migration[5.0]
  def change
    add_column :uploaded_files, :title, :string
  end
end
