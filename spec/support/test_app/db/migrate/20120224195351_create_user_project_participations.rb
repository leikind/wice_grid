# encoding: utf-8
class CreateUserProjectParticipations < ActiveRecord::Migration
  def change
    create_table :user_project_participations do |t|
      t.references :project
      t.references :user
      t.references :project_role

      t.timestamps
    end

    add_index :user_project_participations, :project_id
    add_index :user_project_participations, :user_id
    add_index :user_project_participations, :project_role_id
  end
end
