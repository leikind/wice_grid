# encoding: utf-8
class NullValuesController < ApplicationController
  def index
    @tasks_grid = initialize_grid(Task,
      custom_order: {
        'tasks.priority_id' => 'priorities.name'
      }
    )
  end
end
