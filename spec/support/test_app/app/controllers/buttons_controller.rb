# encoding: utf-8
class ButtonsController < ApplicationController
  def index
    @tasks_grid = initialize_grid(Task)
  end
end
