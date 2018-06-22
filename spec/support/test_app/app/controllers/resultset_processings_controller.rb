# encoding: utf-8
class ResultsetProcessingsController < ApplicationController
  def index
    @tasks_grid = initialize_grid(Task,
      include: [:priority, :status, :project, :assigned_users],
      order: 'statuses.name',
      name: 'g',
      per_page: 10,
      # :with_paginated_resultset => :process_records,
      custom_order: {
        'tasks.priority_id' => 'priorities.name',
        'tasks.status_id' => 'statuses.position',
        'tasks.project_id' => 'projects.name'
      }

    )

    @one_page_records = []

    @tasks_grid.with_paginated_resultset do |records|
      records.each { |rec| @one_page_records << rec }
    end
  end

  protected

  # def process_records(records)
  #   records.each{|rec| @one_page_records << rec}
  # end
end
