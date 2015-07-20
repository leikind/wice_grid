# encoding: utf-8
module Wice #:nodoc:
  module Columns #:nodoc:
    require 'active_support'

    COLUMN_PROCESSOR_INDEX = ActiveSupport::OrderedHash[ #:nodoc:
      :action,                 'column_action',               # Special processor for action column, columns with checkboxes
      :text,                   'column_string',
      :string,                 'column_string',
      :rails_datetime_helper,  'column_rails_datetime_helper',       # standard Rails datepicker helper
      :rails_date_helper,      'column_rails_date_helper',           # standard Rails date helper
      :jquery_datepicker,      'column_jquery_datepicker',
      :bootstrap_datepicker,   'column_bootstrap_datepicker',
      :html5_datepicker,       'column_html5_datepicker',     # not ready
      :integer,                'column_integer',
      :range,                  'column_range',
      :float,                  'column_float',
      :decimal,                'column_float',
      :custom,                 'column_custom_dropdown',      # Special processor for custom filter columns
      :boolean,                'column_boolean'
    ]
  end
end
