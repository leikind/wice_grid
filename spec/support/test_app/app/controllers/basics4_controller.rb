# encoding: utf-8
class Basics4Controller < ApplicationController
  def index
     @tasks_grid = initialize_grid(Task)
  end
end
