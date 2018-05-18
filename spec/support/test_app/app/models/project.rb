# encoding: utf-8
class Project < ActiveRecord::Base
  has_many :tasks
  has_many :user_project_participations

  has_many :users, through: :user_project_participations

  has_many :versions

  belongs_to :customer, class_name: 'Company'
  belongs_to :supplier, class_name: 'Company'

  include ToDropdownMixin
end
