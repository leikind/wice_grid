# encoding: utf-8
class CustomOrderingWithProcController < ApplicationController
  def index
    @status_grid = initialize_grid(Status,
      order: 'statuses.name',
      custom_order: {
        'statuses.name' => ->(column_name) { params[:sort_by_length] ? "length(#{column_name})" : column_name }
      }
    )
  end
end
