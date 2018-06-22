# encoding: utf-8
class Basics3Controller < ApplicationController
  def index
    @tasks_grid = initialize_grid(Task, order: 'id')
  end
end
