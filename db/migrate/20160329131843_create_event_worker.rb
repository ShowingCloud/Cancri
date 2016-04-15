class CreateEventWorker < ActiveRecord::Migration[5.0]
  def change
    create_table :event_workers do |t|
      t.integer :event_id
      t.integer :user_id
      t.boolean :status
      t.integer :worker_type, null: false, default: 1
      t.timestamps
    end
    add_index :event_workers, :event_id
    add_index :event_workers, :user_id
    add_index :event_workers, :status
    add_index :event_workers, [:event_id, :user_id, :worker_type], unique: true
    add_index :event_workers, [:event_id, :user_id]
  end
end
