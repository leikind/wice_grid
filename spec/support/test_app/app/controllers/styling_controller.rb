# encoding: utf-8
class StylingController < ApplicationController
  def index
    @versions_grid1 = initialize_grid(Version, name: 'g1')
    @versions_grid2 = initialize_grid(Version, name: 'g2')
  end
end
