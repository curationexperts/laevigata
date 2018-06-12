class CreateInProgressEtds < ActiveRecord::Migration[5.0]
  def change
    create_table :in_progress_etds do |t|
      t.string :name
      t.string :email
      t.string :graduation_date
      t.string :submission_type
      t.string :user_ppid
      t.timestamps
    end
  end
end
