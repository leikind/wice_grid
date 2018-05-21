# encoding: utf-8
class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :title
      t.text :description
      t.integer :created_by_id
      t.references :project
      t.date :due_date
      t.references :priority
      t.references :status
      t.integer :relevant_version_id
      t.integer :expected_version_id
      t.float :estimated_time
      t.boolean :archived
      t.timestamps
    end

    add_index :tasks, :title
    add_index :tasks, :created_by_id
    add_index :tasks, :project_id
    add_index :tasks, :priority_id
    add_index :tasks, :status_id
    add_index :tasks, :relevant_version_id
    add_index :tasks, :expected_version_id
  end
end
