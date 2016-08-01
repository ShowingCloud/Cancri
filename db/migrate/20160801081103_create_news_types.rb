class CreateNewsTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :news_types do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :news_types, :name, unique: true
  end
end
