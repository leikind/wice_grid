# encoding: utf-8
class Version < ActiveRecord::Base
  belongs_to :project

  include ToDropdownMixin
end
