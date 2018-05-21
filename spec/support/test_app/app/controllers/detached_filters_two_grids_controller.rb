# encoding: utf-8
class DetachedFiltersTwoGridsController < ApplicationController
  def index
    @grid1 = initialize_grid(Task)
    @grid2 = initialize_grid(Task, name: 'grid2')
  end
end
