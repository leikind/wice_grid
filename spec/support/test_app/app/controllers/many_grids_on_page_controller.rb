# encoding: utf-8
class ManyGridsOnPageController < ApplicationController
  def index
    @tasks_grid1 = initialize_grid(Task, name: 'g1')
    @tasks_grid2 = initialize_grid(Task, name: 'g2')
  end
end
