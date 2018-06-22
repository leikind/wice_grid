# encoding: utf-8
class AutoReloads3Controller < ApplicationController
  def index
    @tasks_grid = initialize_grid(Task,
      custom_order: {
        'tasks.priority_id' => 'priorities.name',
        'tasks.status_id' => 'statuses.position',
        'tasks.project_id' => 'projects.name'
      }
    )
    @tasks_grid2 = initialize_grid(Task,
     name: 'grid2',
     custom_order: {
       'tasks.priority_id' => 'priorities.name',
       'tasks.status_id' => 'statuses.position',
       'tasks.project_id' => 'projects.name'
     }
    )
  end
end
