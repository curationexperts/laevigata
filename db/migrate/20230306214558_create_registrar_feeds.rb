class CreateRegistrarFeeds < ActiveRecord::Migration[5.2]
  def change
    create_table :registrar_feeds do |t|
      t.integer :status, default: 0
      t.integer :approved_etds
      t.integer :graduated_etds
      t.integer :published_etds

      t.timestamps
    end
  end
end
