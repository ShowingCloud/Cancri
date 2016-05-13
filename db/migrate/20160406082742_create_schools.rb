class CreateSchools < ActiveRecord::Migration[5.0]
  def change
    create_table :schools do |t|
      t.string :school_type
      t.string :district
      t.string :name
      t.string :school_city
      t.boolean :user_add, null: false, default: false
      t.integer :user_id
      t.timestamps
    end
    add_index :schools, :school_type
    add_index :schools, [:district, :school_type, :name], unique: true, name: 'index_schools'
    add_index :schools, :district
    add_index :schools, [:school_type, :district]
    add_index :schools, :user_add
    add_index :schools, :user_id
  end
end
