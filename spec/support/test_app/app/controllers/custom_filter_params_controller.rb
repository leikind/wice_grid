# encoding: utf-8
class CustomFilterParamsController < ApplicationController
  def index
    @projects_grid = initialize_grid(Project)
  end
end
