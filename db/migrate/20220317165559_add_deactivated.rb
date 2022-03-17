class AddDeactivated < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :deactivated, :boolean, default: false
  end
end
