# encoding: utf-8
class JoiningTablesController < ApplicationController
  def index
    @tasks_grid = initialize_grid(Task,
      # You can omit includes if they are all mentioned in :assoc in the view
      # includes: [:priority, :status, {project: :customer}],
      conditions: { archived: false },
      order: 'id'
    )
  end
end
