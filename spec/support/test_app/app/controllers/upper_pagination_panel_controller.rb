# encoding: utf-8
class UpperPaginationPanelController < ApplicationController
  def index
    @tasks_grid = initialize_grid(Task)
  end
end
