class CreateNews < ActiveRecord::Migration[5.0]
  def change
    create_table :news do |t|
      t.string :name, null: false
      t.string :news_type, null: false
      t.text :desc
      t.string :cover
      t.boolean :status, null: false, default: 0
      t.boolean :is_hot, null: false, default: 0
      t.text :content
      t.integer :admin_id, null: false

      t.timestamps
    end
    add_index :news, :name, unique: true
    add_index :news, :news_type
    add_index :news, :admin_id
    add_index :news, :status
    add_index :news, :is_hot
  end
end
