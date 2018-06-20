class AddDataToInProgressEtds < ActiveRecord::Migration[5.0]
  def change
    add_column :in_progress_etds, :data, :nvarchar
  end
end
