module Wice
  module Controller

    def self.included(base) #:nodoc:
      base.extend(ClassMethods)
    end

    module ClassMethods

      # Used to add query processing action methods into a controller.
      # Read section "Saving Queries How-To" in README for more details.
      def save_wice_grid_queries
        include Wice::SerializedQueriesControllerMixin
      end
    end

    protected

    attr_accessor :wice_grid_instances

    # Creates a grid object to be used in the view. This is the <i>main</i> model, and the underlying table is the default table -
    # if in other parameters a column name is mentioned without the name of the table, this table is implied.
    # Just like in an ordinary ActiveRecord <tt>find</tt> you can use <tt>:joins</tt>, <tt>:include</tt>, and <tt>:conditions</tt>.
    #
    # The first parameter is an ActiveRecord class name. The generated ActiveRecord call will use it as the
    # receiver of the <tt>paginate</tt> method: <tt>klass.paginate(...)</tt>
    #
    # The second parameters is a hash of parameters:
    # * <tt>:joins</tt> - ActiveRecord <tt>:joins</tt> option.
    # * <tt>:include</tt> - ActiveRecord <tt>:include</tt> option.
    # * <tt>:conditions</tt> - ActiveRecord <tt>:conditions</tt> option.
    # * <tt>:per_page</tt> - Number of rows per one page. The default is 10.
    # * <tt>:page</tt> - The page to show when rendering the grid for the first time. The default is one, naturally.
    # * <tt>:order</tt> - Name of the column to sort by. Can be of a short form (just the name of the column) if this
    #   is a column of the main table (the table of the main ActiveRecord model, the first parameter of <tt>initialize_grid</tt>),
    #   or a fully qualified name with the name of the table.
    # * <tt>:order_direction</tt> - <tt>:asc</tt> for ascending or <tt>:desc</tt> for descending. The default is <tt>:asc</tt>.
    # * <tt>:name</tt> - name of the grid. Only needed if there is a second grid on a page. The name serves as the base name for
    #   HTTP parametes, DOM IDs, etc. The shorter the name, the shorter the GET request is. The name can only contain alphanumeruc characters.
    # * <tt>:enable_export_to_csv</tt> - <Enable export of the table to CSV. Read the How-To to learn what else is needed to enable CSV export.
    # * <tt>:csv_file_name</tt> - Name of the exported CSV file. If the parameter is missing, the name of the grid will be used instead.
    # * <tt>:custom_order</tt> - used for overriding the ORDER BY clause with custom sql code (for example, including a function).
    #   The value of the parameter is a hash where keys are fully qualified names
    #   of database columns, and values the required chunks of SQL to use in the ORDER BY clause, either as strings or Proc object
    #   evaluating to string. See section 'Custom Ordering' in the README.
    # * <tt>:saved_query</tt> - id of the saved query or the query object itself to load initially.
    #   Read section "Saving Queries How-To" in README for more details.
    # * <tt>:after</tt> - defined a name of a controller method which would be called by the grid after all user input has been processed,
    #   with a single parameter which is a Proc object. Once called, the object returns a list of all records of the current selection
    #   throughout all pages. See section "Integration With The Application" in the README.
    # * <tt>:total_entries</tt> - If not specified, <tt>will_paginate</tt> will run a <tt>select count</tt>
    #   query to calculate the total number of entries. If specified, the value is passed on to <tt>:total_entries</tt> of 
    #   will_paginate's <tt>paginate</tt> method.    
    #
    # Defaults for parameters <tt>:per_page</tt>, <tt>:order_direction</tt>, <tt>:name</tt>, and <tt>:erb_mode</tt>
    # can be changed in <tt>lib/wice_grid_config.rb</tt>, this is convenient if you want to set a project wide setting
    # without having to repeat it for every grid instance.


    def initialize_grid(klass, opts = {})
      @__wice_grid_on_page = true
      wg = WiceGrid.new(klass, self, opts)
      self.wice_grid_instances = [] if self.wice_grid_instances.nil?
      self.wice_grid_instances << wg
      wg
    end

    # +export_grid_if_requested+ is a controller method which should be called at the end of each action containing grids with enabled
    # CSV export.
    #
    # CSV export will only work if each WiceGrid helper is placed in a partial of its own (requiring it from the master template
    # of course for the usual flow).
    # +export_grid_if_requested+ intercepts CSV export requests and evaluates the corresponding partial with the required  grid helper.
    # By default for each grid +export_grid_if_requested+ will look for a partial
    # whose name follows the following pattern:
    #
    #     _GRID_NAME_grid.html.erb
    #
    # For example, a grid named +orders+ is supposed to be found in a template called <tt>_orders_grid.html.erb</tt>,
    # Remember that the default name of grids is +grid+.
    #
    # This convention can be easily overridden by supplying a hash parameter to +export_grid_if_requested+ where each key is the name of
    # a grid, and the value is the name of the template (like it is specified for +render+, i.e. without '_' and extensions):
    #
    #   export_grid_if_requested(:grid => 'orders', 'grid2' => 'invoices')
    #
    # If the request is not a CSV export request, the method does nothing and returns +false+, if it is a CSV export request,
    # the method returns +true+.
    #
    # If the action has no explicit +render+ call, it's OK to just place +export_grid_if_requested+ as the last line of the action. Otherwise,
    # to avoid double rendering, use the return value of the method to conditionally call your +render+ :
    #
    #    export_grid_if_requested || render(:action => 'index')
    #
    # It's also possible to supply a block which will be called if no CSV export is requested:
    #
    #    export_grid_if_requested do
    #     render(:action => 'index')
    #    end

    def export_grid_if_requested(opts = {})
      grid = self.wice_grid_instances.detect(&:output_csv?)

      if grid
        template_name = opts[grid.name] || opts[grid.name.intern]
        template_name ||= grid.name + '_grid'
        temp_filename = render_to_string(:partial => template_name)
        temp_filename.strip!
        filename = (grid.csv_file_name || grid.name ) + '.csv'
        send_file temp_filename, :filename => filename, :type => 'text/csv'
        true
      else
        yield if block_given?
        false
      end
    end
  end
end
