# encoding: utf-8
class Basics6Controller < ApplicationController
  def index
    @tasks_grid = initialize_grid(Task,
      order: 'tasks.title',
      order_direction: 'desc',
      conditions: { archived: false },
      per_page: 20
    )
  end
end
