class CreateRegulations < ActiveRecord::Migration[5.0]
  def change
    create_table :regulations do |t|
      t.string :name
      t.integer :regulation_type
      t.text :content
      t.timestamps
    end
    add_index :regulations, [:name, :regulation_type], unique: true, name: 'index_on_regulations'
  end
end
