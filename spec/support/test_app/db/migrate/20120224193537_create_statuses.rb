# encoding: utf-8
class CreateStatuses < ActiveRecord::Migration
  def change
    create_table :statuses do |t|
      t.string :name
      t.integer :position
      t.timestamps
    end

    add_index :statuses, :name
    add_index :statuses, :position
  end
end
