class AddColumnToScores < ActiveRecord::Migration[5.0]
  def change
    add_column :scores, :confirm_sign, :string
    add_column :scores, :note_img, :string
  end
end
