# encoding: utf-8
class CustomOrderingWithRubyController < ApplicationController
  def index
    @status_grid = initialize_grid(Status)
  end
end
