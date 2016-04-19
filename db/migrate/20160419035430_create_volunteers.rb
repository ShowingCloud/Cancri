class CreateVolunteers < ActiveRecord::Migration[5.0]
  def change
    create_table :volunteers do |t|
      t.integer :competition_id, null: false
      t.integer :news_type_id, null: false
      t.text :content
      t.integer :status
      t.string :address
      t.datetime :apply_start_time, null: false
      t.datetime :apply_end_time, null: false

      t.timestamps
    end
    add_index :volunteers, :competition_id
    add_index :volunteers, :status
    add_index :volunteers, :apply_start_time
    add_index :volunteers, :apply_end_time
    add_index :volunteers, :news_type_id
    add_index :volunteers, [:news_type_id, :competition_id], unique: true, name: 'index_volunteers'
  end
end
