class AddColumnToSchoolsTeams < ActiveRecord::Migration[5.0]
  def change
    add_column :schools, :teacher_role, :integer
    add_index :schools, :teacher_role
    remove_index :teams, [:event_id, :name]
    change_column :teams, :status, :integer, null: false, default: 0
    add_index :teams, :status
    add_index :teams, [:school_id, :event_id, :status], name: 'school_index_on_teams'
    add_index :teams, [:district_id, :event_id, :status], name: 'district_index_on_teams'
  end
end
