# encoding: utf-8
class ActionColumnController < ::ApplicationController
  def index
    @tasks_grid = initialize_grid(Task,
      include: [:priority, :status, :project, :assigned_users],
      name:    'g',
      order:   'id'
    )
    if params[:g] && params[:g][:selected]
      @selected = params[:g][:selected]
    end
  end
end
