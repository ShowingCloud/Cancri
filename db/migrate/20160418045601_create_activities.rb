class CreateActivities < ActiveRecord::Migration[5.0]
  def change
    create_table :activities do |t|
      t.string :name, null: false
      t.text :content, null: false
      t.integer :status
      t.string :cover
      t.string :host_address, null: false
      t.integer :host_year, null: false
      t.datetime :apply_start_time, null: false
      t.datetime :apply_end_time, null: false
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false

      t.timestamps
    end

    add_index :activities, :name, unique: true
    add_index :activities, :status
    add_index :activities, :host_year
    add_index :activities, :start_time
    add_index :activities, :end_time
    add_index :activities, :apply_end_time
  end
end
