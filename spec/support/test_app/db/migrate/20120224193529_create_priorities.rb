# encoding: utf-8
class CreatePriorities < ActiveRecord::Migration
  def change
    create_table :priorities do |t|
      t.string :name
      t.integer :position
      t.timestamps
    end

    add_index :priorities, :name
    add_index :priorities, :position
  end
end
