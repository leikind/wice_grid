# encoding: utf-8
class DisableAllFiltersController < ApplicationController
  def index
     @tasks_grid = initialize_grid(Task)
  end
end
