class AddEtdIdToInProgressEtds < ActiveRecord::Migration[5.1]
  def change
    add_column :in_progress_etds, :etd_id, :string
  end
end
