ENV['RAILS_ENV'] = 'test'
ENV['RAILS_ROOT'] ||= File.dirname(__FILE__) + '/../../../..'

ENV['DB'] =  'mysql'

require 'test/unit'
require File.expand_path(File.join(ENV['RAILS_ROOT'], 'config/environment.rb'))

def load_schema

  config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
  ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")

  db_adapter = ENV['DB']

  # no db passed, try one of these fine config-free DBs before bombing.
  db_adapter ||=
    begin
      require 'rubygems'
      require 'sqlite'
      'sqlite'
    rescue MissingSourceFile
      begin
        require 'sqlite3'
        'sqlite3'
      rescue MissingSourceFile
      end
    end

  if db_adapter.nil?
    raise "No DB Adapter selected. Pass the DB= option to pick one, or install Sqlite or Sqlite3."
  end

  ActiveRecord::Base.establish_connection(config[db_adapter])
  load(File.dirname(__FILE__) + "/schema.rb")
  require File.dirname(__FILE__) + '/../init.rb'
  
end

#
#
#

require File.join(File.dirname(__FILE__), '../generators/wice_grid_assets/templates/initializers/wice_grid_config.rb')

load_schema

class Person < ActiveRecord::Base
  has_many :projects
  has_many :tasks
end

class Project < ActiveRecord::Base
  belongs_to :person
  validates_presence_of :person_id
end

class Task < ActiveRecord::Base
  belongs_to :project
  belongs_to :person
  validates_presence_of :project_id
  validates_presence_of :person_id
end

class SavedQuery < ActiveRecord::Base
  def self.list(a, b)
  end
end

NUM_PEOPLE   = 10
NUM_PROJECTS = 5
NUM_TASKS    = 1000

NUM_PEOPLE.times do |i|
  Person.create!(:firstname => "Firstname%02d" % i, :lastname => "Lastname%02d" % i, :email => "user%02d@example.com" % i)
end

NUM_PROJECTS.times do |i|
  Project.create!(:name => "Project%02d" % i, :person => Person.all[i % NUM_PEOPLE])
end

NUM_TASKS.times do |i|
  project = Project.find(:first, :order => 'RAND()')
  owner = Person.find(:first, :order => 'RAND()')
  Task.create!(:name => "Task%03d" % i, 
               :description => "Description%03d" % i, 
               :person => Person.all[i % NUM_PEOPLE], 
               :project => Project.all[i % NUM_PROJECTS])
end
