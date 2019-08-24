class AddColumnsToPhotosAndVideos < ActiveRecord::Migration[5.0]
  def change
    add_column :photos, :type_id, :integer
    add_column :photos, :photo_type, :integer, null: false, default: 0
    add_column :videos, :type_id, :integer
    add_column :videos, :video_type, :integer, null: false, default: 0
    add_index :photos, :type_id
    add_index :photos, :photo_type
    add_index :photos, [:type_id, :photo_type]
    add_index :videos, :type_id
    add_index :videos, :video_type
    add_index :videos, [:type_id, :video_type]
  end
end
