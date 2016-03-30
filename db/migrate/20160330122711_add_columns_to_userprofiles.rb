class AddColumnsToUserprofiles < ActiveRecord::Migration[5.0]
  def change
    add_column :user_profiles, :teacher_no, :string
    add_column :user_profiles, :certificate, :string
    add_index :user_profiles, :teacher_no
  end
end
