# encoding: utf-8
class IntegrationWithFormsController < ApplicationController
  def index
    @archived = params[:archived] == '1' ? true : false

    @tasks_grid = initialize_grid(Task,
      conditions: { archived: @archived },
      name: 'g'
    )
  end
end
