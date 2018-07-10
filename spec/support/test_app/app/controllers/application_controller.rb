# encoding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery

  before_action :init_example_map
  before_action :init_current_example_map

  protected

  def init_current_example_map
    @controller_file_to_show = 'app/controllers/' + controller_name + '_controller.rb'
    @controller_file = File.join(Rails.root, @controller_file_to_show)

    @view_files_dir = {}
    view_files_dir = File.join(Rails.root, 'app/views/' + controller_name)
    Dir.glob("#{view_files_dir}/*").each do |fullpath|
      fullpath =~ /^.+(app\/views\/.+)$/
      @view_files_dir[Regexp.last_match(1)] = fullpath
    end
  end

  def init_example_map
    @example_map = [
      ['Basics',
       [
         [:basics1, 'Most simple grid'],
         [:basics2, 'Named columns'],
         [:upper_pagination_panel, 'Two pagination panels'],
         [:basics3, 'Associating columns with database fields'],

         [:blockless_column_definition, 'Dropping the block in #column'],
         [:numeric_filters, 'Numeric filters'],
         [:many_grids_on_page, 'More than 1 grid on a page'],
         [:basics4, 'Disabling filters'],
         [:disable_all_filters, 'Disabling all filters'],
         [:dates, 'Date/Datetime helpers'],
         [:when_filtered, 'Hidden filter panel'],
         [:basics5, 'Disabling ordering'],
         [:basics6, 'Initial conditions and ordering'],
         [:buttons, 'External submit/reset buttons'],
         [:detached_filters, 'External filters'],
         [:detached_filters_two_grids, 'External filters (example with 2 grids)'],
         [:no_records, 'A grid without records']

       ]
      ],

      ['Joined tables',
       [
         [:joining_tables, 'Joined tables'],
         [:two_associations, '2 associations to the same table']
       ]
      ],

      ['Custom filters and ordering',
       [
         [:custom_ordering, 'Custom ordering (with String)'],
         [:custom_ordering_with_arel, 'Custom ordering (with Arel)'],
         [:custom_ordering_with_proc, 'Custom ordering (with Proc)'],
         [:custom_ordering_with_ruby, 'Custom ordering (with arbitrary Ruby)'],
         [:custom_ordering_on_calculated, 'Custom ordering (on a calculated field)'],
         [:custom_filters1, 'Custom filters (one table)'],
         [:custom_filters2, 'Custom filters (joined tables)'],
         [:custom_filters3, 'Custom filters (method chains)'],
         [:custom_filters4, 'Custom filters: turning off multiple selection'],
         [:null_values, 'Custom filters (null values)']
       ]
      ],

      ['Miscellaneous',
       [
         [:styling, 'Styling the grid'],
         [:negation, 'Text filters with negation'],
         [:adding_rows, 'Adding custom rows'],
         [:all_records, 'Removing link "All Records"'],
         [:csv_export, 'CSV export'],
         [:csv_and_detached_filters, 'CSV export and external filters'],
         [:auto_reloads, 'Auto reloading filters'],
         [:auto_reloads2, 'Auto reloading filters (external filters)'],
         [:auto_reloads3, 'Auto reloading filters (two grids on page)']
       ]
      ],

      ['Integration with the application',
       [
         [:action_column, 'Action column'],
         [:hiding_checkboxes_in_action_column, 'Hiding certain checkboxes in the action column'],
         [:integration_with_forms, 'Integration with other forms'],
         [:integration_with_application_view, 'View helpers to access records on the current page and all pages'],
         [:resultset_processings, 'Callback to process records of the current page'],
         [:resultset_processings2, 'Callback to process records throughout all pages on demand'],
         [:localization, 'Localization'],
         [:custom_filter_params, 'Generating custom filter parameters'],
         [:saved_queries, 'Saved queries: simple example']
       ]
      ]
    ]
  end
end
