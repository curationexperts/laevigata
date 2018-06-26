class ChangeDataToVarcharInProgressEtds < ActiveRecord::Migration[5.1]
  def change
    change_column :in_progress_etds, :data, :varchar
  end
end
