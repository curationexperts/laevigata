class AddPpidIndexToUsers < ActiveRecord::Migration[5.0]
  def change
    add_index :users, :ppid, name: "index_users_on_ppid", unique: true
  end
end
