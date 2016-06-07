class WiceGridSerializedQuery < ActiveRecord::Base  #:nodoc:
  serialize :query

  validates_uniqueness_of :name, scope: :grid_name, on: :create, message: 'A query with this name already exists'

  validates_presence_of :name, message: 'Please submit the name of the custom query'

  # returns a list of all serialized queries
  def self.list(name, _controller)
    conditions = { grid_name: name }
    self.where(conditions).to_a
  end
end
