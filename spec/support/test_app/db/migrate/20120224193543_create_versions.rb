# encoding: utf-8
class CreateVersions < ActiveRecord::Migration
  def change
    create_table :versions do |t|
      t.string :name
      t.references :project
      t.string :status
      t.timestamps
    end

    add_index :versions, :name
    add_index :versions, :project_id
    add_index :versions, :status
  end
end
