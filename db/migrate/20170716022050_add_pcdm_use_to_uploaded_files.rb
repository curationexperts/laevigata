class AddPcdmUseToUploadedFiles < ActiveRecord::Migration[5.0]
  def change
    add_column :uploaded_files, :pcdm_use, :string
  end
end
