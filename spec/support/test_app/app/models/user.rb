# encoding: utf-8
class User < ActiveRecord::Base
  has_many :created_tasks, class_name: 'Task', foreign_key: :created_by_id
  has_and_belongs_to_many :assigned_tasks, class_name: 'Task'

  has_many :user_project_participations
  has_many :projects, through: :user_project_participations
end
