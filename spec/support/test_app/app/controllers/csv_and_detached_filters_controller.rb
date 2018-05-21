# encoding: utf-8
class CsvAndDetachedFiltersController < ApplicationController
  def index
    @tasks_grid = initialize_grid(Task,
      name: 'grid',
      enable_export_to_csv: true,
      csv_field_separator: ';',
      csv_file_name: 'tasks'
    )

    export_grid_if_requested('grid' => 'grid')
  end
end
