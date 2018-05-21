# encoding: utf-8
class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.integer :customer_id
      t.integer :supplier_id
      t.timestamps
    end

    add_index :projects, :customer_id
    add_index :projects, :supplier_id
  end
end
