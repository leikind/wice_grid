# encoding: utf-8
class Basics2Controller < ApplicationController
  def index
    @tasks_grid = initialize_grid(Task)
  end
end
