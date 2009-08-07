ActiveRecord::Schema.define(:version => 0) do
  
  create_table :people, :force => true do |t|
    t.string :firstname
    t.string :lastname
    t.string :email
    t.timestamps
  end
  
  create_table :projects, :force => true do |t|
    t.string  :name
    t.integer :person_id
    t.timestamps
  end
  
  create_table :tasks, :force => true do |t|
    t.integer :project_id
    t.integer :person_id
    t.string  :name
    t.text    :description
    t.boolean :done
    t.timestamps
  end
  
  create_table :saved_queries, :force => true  do |t|
    t.column :name,      :string
    t.column :grid_name, :string
    t.column :query,     :text
    t.column :grid_hash, :string

    t.timestamps
  end  
end