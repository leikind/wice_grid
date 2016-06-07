ActiveRecord::Schema.define(version: 20150713103513) do
  create_table 'dummies', force: :cascade do |t|
    t.string 'name'

    t.datetime 'created_at'
    t.datetime 'updated_at'
  end
end
