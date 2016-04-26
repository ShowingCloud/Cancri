class CreatePhotos < ActiveRecord::Migration[5.0]
  def change
    create_table :photos do |t|
      t.integer :competition_id
      t.string :image
      t.integer :status
      t.integer :sort
      t.string :desc

      t.timestamps
    end

    add_index :photos, :competition_id
    add_index :photos, [:competition_id, :sort]
    add_index :photos, :status
    add_index :photos, :sort
  end
end
