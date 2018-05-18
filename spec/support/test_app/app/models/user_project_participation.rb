# encoding: utf-8
class UserProjectParticipation < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :project_role
end
