# encoding: utf-8
class Priority < ActiveRecord::Base
  has_many :tasks

  include ToDropdownMixin

  def self.urgent
    find_by_name('Urgent')
  end
end
