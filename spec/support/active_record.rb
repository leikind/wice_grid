require 'active_record'

ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'

load 'spec/schema.rb'

class Dummy < ActiveRecord::Base
end

Dummy.create(name: 'test')