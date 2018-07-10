# encoding: utf-8
class CustomOrderingOnCalculatedController < ApplicationController
  def index
    @status_grid = initialize_grid(Status)
  end
end
