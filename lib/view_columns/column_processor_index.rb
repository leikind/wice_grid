# encoding: UTF-8
module Wice
  COLUMN_PROCESSOR_INDEX = {
    :action     => 'action_view_column', # Special processor for action column, columns with checkboxes
    :text       => 'view_column_string',
    :string     => 'view_column_string',
    :timestamp  => 'view_column_datetime',
    :datetime   => 'view_column_datetime',
    :date       => 'view_column_date',
    :integer    => 'view_column_integer',
    :float      => 'view_column_float',
    :decimal    => 'view_column_float',
    :custom     => 'view_column_custom_dropdown',  # Special processor for custom filter columns
    :boolean    => 'view_column_boolean'
  }
end