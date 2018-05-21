# encoding: utf-8
class BlocklessColumnDefinitionController < ApplicationController
  def index
     @tasks_grid = initialize_grid(Task, order: 'id')
  end
end
