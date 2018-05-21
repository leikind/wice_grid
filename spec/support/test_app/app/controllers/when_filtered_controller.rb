# encoding: utf-8
class WhenFilteredController < ApplicationController
  def index
    @tasks_grid = initialize_grid(Task)
  end
end
