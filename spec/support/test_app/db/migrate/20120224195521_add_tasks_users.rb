# encoding: utf-8
class AddTasksUsers < ActiveRecord::Migration
  def change
    create_table :tasks_users, id: false do |t|
      t.integer :task_id, :user_id
    end

    add_index :tasks_users, :task_id
    add_index :tasks_users, :user_id
  end
end
