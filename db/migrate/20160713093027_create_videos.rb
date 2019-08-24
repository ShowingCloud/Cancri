class CreateVideos < ActiveRecord::Migration[5.0]
  def change
    create_table :videos do |t|
      t.integer :competition_id
      t.string :video
      t.boolean :status, default: false
      t.integer :sort
      t.string :desc

      t.timestamps
    end

    add_index :videos, :competition_id
    add_index :videos, [:competition_id, :sort]
    add_index :videos, :status
    add_index :videos, :sort
  end
end
