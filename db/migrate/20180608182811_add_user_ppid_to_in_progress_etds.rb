class AddUserPpidToInProgressEtds < ActiveRecord::Migration[5.0]
  def change
    add_column :in_progress_etds, :user_ppid, :string
  end
end
