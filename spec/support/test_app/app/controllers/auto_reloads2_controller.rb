# encoding: utf-8
class AutoReloads2Controller < ApplicationController
  def index
    @tasks_grid = initialize_grid(Task,
      custom_order:  {
        'tasks.priority_id' => 'priorities.name',
        'tasks.status_id' => 'statuses.position',
        'tasks.project_id' => 'projects.name'
      },
      order:  'id',
      order_direction:  'asc'
    )
  end
end
