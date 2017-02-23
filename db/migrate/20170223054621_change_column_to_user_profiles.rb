class ChangeColumnToUserProfiles < ActiveRecord::Migration[5.0]
  def change
    change_column :user_profiles, :standby_school, :string
  end
end
