class WiceGridSerializedQuery < ActiveRecord::Base  #:nodoc:
  serialize :query

  validates_uniqueness_of :name, :scope => :grid_name, :on => :create, 
    :message => ::Wice::WiceGridNlMessageProvider.get_message(:VALIDATES_UNIQUENESS_ERROR)
  validates_presence_of :name, :message => ::Wice::WiceGridNlMessageProvider.get_message(:VALIDATES_PRESENCE_ERROR)

  def self.list(name, controller)
    conditions = {:grid_name => name}
    self.find(:all, :conditions => conditions)
  end

end