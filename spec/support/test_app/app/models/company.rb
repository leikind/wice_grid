# encoding: utf-8
class Company < ActiveRecord::Base
  has_many :customer_projects, class_name: 'Project', foreign_key: 'customer_id'
  has_many :supplier_projects, class_name: 'Project', foreign_key: 'supplier_id'
end
