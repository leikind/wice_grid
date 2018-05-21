# encoding: utf-8
class Task < ActiveRecord::Base
  belongs_to :created_by, class_name: 'User'
  belongs_to :project
  belongs_to :priority
  belongs_to :status
  belongs_to :relevant_version, class_name: 'Version'
  belongs_to :expected_version, class_name: 'Version'

  has_and_belongs_to_many :assigned_users, -> { order('users.name') }, class_name: 'User'
end
