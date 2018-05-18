# encoding: utf-8
class TwoAssociationsController < ApplicationController
  def index
    @projects_grid = initialize_grid(Project)
  end
end
