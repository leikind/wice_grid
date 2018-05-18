# encoding: utf-8
class ResultsetProcessings2Controller < ApplicationController
  attr_reader :selected_tasks

  def index
    @tasks_grid = initialize_grid(Task,
      include: [:priority, :status, :project, :assigned_users],
      order: 'statuses.name',
      name: 'g',
      per_page: 5,
      with_resultset: :process_records,
      custom_order: {
        'tasks.priority_id' => 'priorities.name',
        'tasks.status_id' => 'statuses.position',
        'tasks.project_id' => 'projects.name'
      }
    )

    @selected_tasks = []
  end

  protected

  def process_records(active_relation)
    if params[:process_selected_tasks]
      @selected_tasks = active_relation.to_a
    end
  end
end
