# encoding: utf-8
class NegationController < ApplicationController
  def index
    @tasks_grid = initialize_grid(Task,
      include: [:priority, :status, :project],
      order: 'statuses.name',
      custom_order: {
        'tasks.priority_id' => 'priorities.name',
        'tasks.status_id'   => 'statuses.position',
        'tasks.project_id'  => 'projects.name'
      }
    )
  end
end
