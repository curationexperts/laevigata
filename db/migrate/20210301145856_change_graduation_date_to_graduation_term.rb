class ChangeGraduationDateToGraduationTerm < ActiveRecord::Migration[5.2]
  def change
    rename_column :in_progress_etds, :graduation_date, :graduation_term
  end
end
