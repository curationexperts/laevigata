class AddDataToInProgressEtds < ActiveRecord::Migration[5.1]
  def change
    add_column :in_progress_etds, :data, :varchar
  end
end
