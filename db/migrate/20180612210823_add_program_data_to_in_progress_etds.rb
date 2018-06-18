class AddProgramDataToInProgressEtds < ActiveRecord::Migration[5.0]
  def change
    add_column :in_progress_etds, :department, :string
    add_column :in_progress_etds, :degree, :string
    add_column :in_progress_etds, :subfield, :string
    add_column :in_progress_etds, :partnering_agency, :string
  end
end
