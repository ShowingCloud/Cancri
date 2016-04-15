class CreateClient < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.string :name
      t.string :app_id
      t.string :app_secret

      t.timestamps
    end
    add_index :clients, :app_id, unique: true
    add_index :clients, :app_secret, unique: true
  end
end
