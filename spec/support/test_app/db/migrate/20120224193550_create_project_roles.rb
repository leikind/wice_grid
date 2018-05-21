# encoding: utf-8
class CreateProjectRoles < ActiveRecord::Migration
  def change
    create_table :project_roles do |t|
      t.string :name
      t.boolean :can_close_tasks
      t.timestamps
    end

    add_index :project_roles, :name
  end
end
