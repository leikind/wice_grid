# encoding: UTF-8
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

    attr_accessor :wice_grid_instances #:nodoc:

    # Creates a grid object to be used in the view. This is the <i>main</i> model, and the underlying table is the default table -
    # if in other parameters a column name is mentioned without the name of the table, this table is implied.
    # Just like in an ordinary ActiveRecord <tt>find</tt> you can use <tt>:joins</tt>, <tt>:include</tt>, and <tt>:conditions</tt>.
    #
    # The first parameter is an ActiveRecord class name or an  ActiveRecord::Relation instance. The generated ActiveRecord call will use it as the
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
    # * <tt>:csv_field_separator</tt> - field separator for CSV files. The default is defined in +CSV_FIELD_SEPARATOR+ in the config file.
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
    # * <tt>:select</tt> - ActiveRecord <tt>:select</tt> option. Please do not forget that <tt>:select</tt> is ignored
    #   when <tt>:include</tt> is present. It is unlikely you would need <tt>:select</tt> with WiceGrid, but if you do,
    #   use it with care :)
    # * <tt>:group</tt> - ActiveRecord <tt>:group</tt> option. Use it if you are sure you know what you are doing :)
    # * <tt>:with_paginated_resultset</tt> - a callback executed from within the plugin to process records of the current page.
    #   Can be a lambda object or a controller method name (symbol). The argument to the callback is the array of the records.
    # * <tt>:with_resultset</tt> - a callback executed from within the plugin to process all records browsable through
    #   all pages with the current filters. Can be a lambda object or a controller method name (symbol). The argument to
    #   the callback is a lambda object which returns the list of records when called. See the README for the explanation.
    #
    # Defaults for parameters <tt>:per_page</tt>, <tt>:order_direction</tt>, and <tt>:name</tt>
    # can be changed in <tt>lib/wice_grid_config.rb</tt>, this is convenient if you want to set a project wide setting
    # without having to repeat it for every grid instance.


    def initialize_grid(klass, opts = {})
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
        temp_filename = temp_filename.strip
        filename = (grid.csv_file_name || grid.name ) + '.csv'
        grid.csv_tempfile.close
        send_file_rails2 temp_filename, :filename => filename, :type => 'text/csv; charset=utf-8'
        grid.csv_tempfile = nil
        true
      else
        yield if block_given?
        false
      end
    end

    # +wice_grid_custom_filter_params+ generates HTTP parameters understood by WiceGrid custom filters.
    # Combined with Rails route helpers it allows to generate links leading to
    # grids with pre-selected custom filters.
    #
    # Parameters:
    # * <tt>:grid_name</tt> - The name of the grid. Just like parameter <tt>:name</tt> of
    #   <tt>initialize_grid</tt>, the parameter is optional, and when absent, the name
    #   <tt>'grid'</tt> is assumed
    # * <tt>:attribute</tt> and <tt>:model</tt> - should be the same as <tt>:attribute</tt> and
    #   <tt>:model</tt> of the column declaration with the target custom filter.
    # * <tt>:value</tt> - the value of the column filter.
    def wice_grid_custom_filter_params(opts = {})
      options = {:grid_name => 'grid',
                 :attribute => nil,
                 :model => nil,
                 :value => nil}
      options.merge!(opts)

      [:attribute, :value].each do |key|
        raise ::Wice::WiceGridArgumentError.new("wice_grid_custom_filter_params: :#{key} is a mandatory argument") unless options[key]
      end

      attr_name = if options[:model]
        unless options[:model].nil?
          options[:model] = options[:model].constantize if options[:model].is_a? String
          raise Wice::WiceGridArgumentError.new("Option :model can be either a class or a string instance") unless options[:model].is_a? Class
        end
        options[:model].table_name + '.' + options[:attribute]
      else
        options[:attribute]
      end

      {"#{options[:grid_name]}[f][#{attr_name}][]" => options[:value]}
    end

    private


    def send_file_rails2(path, options = {}) #:nodoc:
      raise "Cannot read file #{path}" unless File.file?(path) and File.readable?(path)

      options[:length]   ||= File.size(path)
      options[:filename] ||= File.basename(path) unless options[:url_based_filename]
      send_file_headers_rails2! options

      @performed_render = false

      logger.info "Sending file #{path}" unless logger.nil?
      File.open(path, 'rb') { |file| render :status => options[:status], :text => file.read }
    end


    DEFAULT_SEND_FILE_OPTIONS_RAILS2 = { #:nodoc:
      :type         => 'application/octet-stream'.freeze,
      :disposition  => 'attachment'.freeze,
      :stream       => true,
      :buffer_size  => 4096,
      :x_sendfile   => false
    }.freeze

    def send_file_headers_rails2!(options) #:nodoc:

      options.update(DEFAULT_SEND_FILE_OPTIONS_RAILS2.merge(options))
      [:length, :type, :disposition].each do |arg|
        raise ArgumentError, ":#{arg} option required" if options[arg].nil?
      end

      disposition = options[:disposition].dup || 'attachment'

      disposition <<= %(; filename="#{options[:filename]}") if options[:filename]

      content_type = options[:type]
      content_type = content_type.to_s.strip # fixes a problem with extra '\r' with some browsers

      headers.merge!(
        'Content-Length'            => options[:length].to_s,
        'Content-Type'              => content_type,
        'Content-Disposition'       => disposition,
        'Content-Transfer-Encoding' => 'binary'
      )

      # Fix a problem with IE 6.0 on opening downloaded files:
      # If Cache-Control: no-cache is set (which Rails does by default),
      # IE removes the file it just downloaded from its cache immediately
      # after it displays the "open/save" dialog, which means that if you
      # hit "open" the file isn't there anymore when the application that
      # is called for handling the download is run, so let's workaround that
      headers['Cache-Control'] = 'private' if headers['Cache-Control'] == 'no-cache'
    end

  end
end
