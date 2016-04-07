class CreateSchools < ActiveRecord::Migration[5.0]
  def change
    create_table :schools do |t|
      t.string :school_type
      t.string :district
      t.string :name
      t.string :school_city
      t.timestamps
    end
    add_index :schools, :school_type
    add_index :schools, [:name, :school_type], unique: true
    add_index :schools, :district
    add_index :schools, [:school_type, :district]
  end
end
