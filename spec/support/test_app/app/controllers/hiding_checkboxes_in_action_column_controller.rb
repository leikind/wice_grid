# encoding: utf-8
class HidingCheckboxesInActionColumnController < ApplicationController
  def index
    @tasks_grid = initialize_grid(Task,
      name: 'g',
      order: 'id'
    )

    if params[:g] && params[:g][:selected]
      @selected = params[:g][:selected]
    end
  end
end
