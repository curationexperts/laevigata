class ChangeDataToVarcharInProgressEtds < ActiveRecord::Migration[5.1]
  def change
    #change_column :in_progress_etds, :data, :varchar
    reversible do |column|
        column.up   { change_column :in_progress_etds, :data, :varchar }
        column.down { change_column :in_progress_etds, :data, :nvarchar }
    end
  end
end
