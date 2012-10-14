# encoding: UTF-8
module Wice
  module Columns
    COLUMN_PROCESSOR_INDEX = ActiveSupport::OrderedHash[
      :action   , 'column_action', # Special processor for action column, columns with checkboxes
      :text     , 'column_string',
      :string   , 'column_string',
      :timestamp, 'column_datetime',
      :datetime , 'column_datetime',
      :date     , 'column_date',
      :integer  , 'column_integer',
      :float    , 'column_float',
      :decimal  , 'column_float',
      :custom   , 'column_custom_dropdown',  # Special processor for custom filter columns
      :boolean  , 'column_boolean'
    ]
  end
end