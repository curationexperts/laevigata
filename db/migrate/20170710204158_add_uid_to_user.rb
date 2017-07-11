class AddUidToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :uid, :string
  end
end
