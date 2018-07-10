# encoding: utf-8
class Status < ActiveRecord::Base
  has_many :tasks

  include ToDropdownMixin

  def number_of_vowels
    name.scan(/[aeiou]/i).count
  end
end
