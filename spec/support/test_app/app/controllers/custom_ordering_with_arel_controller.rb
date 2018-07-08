# encoding: utf-8
class CustomOrderingWithArelController < ApplicationController
  def index
    @status_grid1 = initialize_grid(Status,
      order: 'statuses.name',
      custom_order: {
        'statuses.name' => Arel.sql('length( ? )')
      }
    )
    @status_grid2 = initialize_grid(Status,
      name: 'g2',
      order: 'statuses.name',
      custom_order: {
        'statuses.name' => Status.arel_table[:position]
      }
    )
  end
end
