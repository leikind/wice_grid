# encoding: utf-8
module Wice
  class GridRenderer
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::CaptureHelper
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::AssetTagHelper
    include ActionView::Helpers::JavaScriptHelper

    attr_reader :page_parameter_name
    attr_reader :after_row_handler
    attr_reader :before_row_handler
    attr_reader :replace_row_handler
    attr_reader :blank_slate_handler
    attr_reader :last_row_handler
    attr_reader :grid
    attr_reader :kaption

    @@order_parameter_name = 'order'
    @@order_direction_parameter_name = 'order_direction'
    @@page_parameter_name = 'page'

    def initialize(grid, view)  #:nodoc:
      @grid = grid
      @grid.renderer = self
      @columns = []
      @columns_table = {}
      @action_column_present = false
      @view = view
    end

    def config  #:nodoc:
      @view.config
    end

    def controller  #:nodoc:
      @view.controller
    end

    def add_column(vc)  #:nodoc:
      @columns_table[vc.fully_qualified_attribute_name] = vc if vc.attribute
      @columns << vc
    end

    def [](k)  #:nodoc:
      @columns_table[k]
    end

    def number_of_columns(filter = nil)  #:nodoc:
      filter_columns(filter).size
    end

    def each_column_label(filter = nil)  #:nodoc:
      filter_columns(filter).each { |col| yield col.name }
    end

    def column_labels(filter = nil)  #:nodoc:
      filter_columns(filter).collect(&:name)
    end

    def each_column(filter = nil)  #:nodoc:
      filter_columns(filter).each { |col| yield col }
    end

    def each_column_aware_of_one_last_one(filter = nil)  #:nodoc:
      cols = filter_columns(filter)
      cols[0..-2].each { |col| yield col, false }
      yield cols.last, true
    end

    def last_column_for_html  #:nodoc:
      filter_columns(:in_html).last
    end

    def select_for(filter)  #:nodoc:
      filter_columns(filter).select { |col| yield col }
    end

    def find_one_for(filter)  #:nodoc:
      filter_columns(filter).find { |col| yield col }
    end

    def each_column_with_attribute  #:nodoc:
      @columns.select(&:attribute).each { |col| yield col }
    end

    alias_method :each, :each_column
    include Enumerable

    def csv_export_icon #:nodoc:
      content_tag(
        :div,
        content_tag(:i, '', class: 'fa fa-file-excel-o'),
        title: NlMessage['csv_export_tooltip'],
        class: 'clickable export-to-csv-button'
      )
    end

    def pagination_panel(number_of_columns, hide_csv_button)  #:nodoc:
      panel = yield

      render_csv_button = @grid.export_to_csv_enabled && !hide_csv_button

      if panel.nil?
        if render_csv_button
          "<tr><td colspan=\"#{number_of_columns}\"></td><td>#{csv_export_icon}</td></tr>"
        else
          ''
        end
      else
        if render_csv_button
          "<tr><td colspan=\"#{number_of_columns}\">#{panel}</td><td>#{csv_export_icon}</td></tr>"
        else
          "<tr><td colspan=\"#{number_of_columns + 1}\">#{panel}</td></tr>"
        end
      end
    end

    # Takes one argument and adds the  <caption></caption> tag to the table with the argument value as
    # the contents of <caption>.
    def caption(kaption)
      @kaption = kaption
    end

    # Adds a column with checkboxes for each record. Useful for actions with multiple records, for example, deleting
    # selected records. Please note that +action_column+ only creates the checkboxes and the 'Select All' and
    # 'Deselect All' buttons, and the form itelf as well as processing the parameters should be taken care of
    # by the application code.
    #
    # * <tt>:param_name</tt> - The name of the HTTP parameter.
    #   The complete HTTP parameter is <tt>"#{grid_name}[#{param_name}][]"</tt>.
    #   The default param_name is 'selected'.
    # * <tt>:html</tt> - a hash of HTML attributes to be included into the <tt>td</tt> tag.
    # * <tt>:select_all_buttons</tt> - show/hide buttons 'Select All' and 'Deselect All' in the column header.
    #   The default is +true+.
    # * <tt>:object_property</tt> - a method used to obtain the value for the HTTP parameter. The default is +id+.
    # * <tt>:html_check_box</tt> - can be used to switch from a real check box to two images. The default is +true+.
    #
    # You can hide a certain action checkbox if you add the usual block to +g.action_column+, just like with the
    # +g.column+ definition. If the block returns +nil+ or +false+ no checkbox will be rendered.

    def action_column(opts = {}, &block)
      if @action_column_present
        fail Wice::WiceGridException.new('There can be only one action column in a WiceGrid')
      end

      options = {
        param_name:          :selected,
        html:                {},
        select_all_buttons:  true,
        object_property:     :id,
        html_check_box:      true
      }

      opts.assert_valid_keys(options.keys)
      options.merge!(opts)
      @action_column_present = true
      column_processor_klass = Columns.get_view_column_processor(:action)

      @columns << column_processor_klass.new(
        @grid,
        options[:html],
        options[:param_name],
        options[:select_all_buttons],
        options[:object_property],
        options[:html_check_box],
        @view,
        block
      )
    end

    # Defines everything related to a column in a grid - column name, filtering, rendering cells, etc.
    #
    # +column+ is only used inside the block of the +grid+ method. See documentation for the +grid+ method for more details.
    #
    # The only parameter is a hash of options. None of them is optional. If no options are supplied, the result will be a
    # column with no name, no filtering and no sorting.
    #
    # * <tt>:name</tt> - Name of the column.
    # * <tt>:html</tt> - a hash of HTML attributes to be included into the <tt>td</tt> tag.
    # * <tt>:class</tt> - a shortcut for <tt>html: {class: 'css_class'}</tt>
    # * <tt>:attribute</tt> - name of a database column (which normally correspond to a model attribute with the
    #   same name). By default the field is assumed to belong to the default table (see documentation for the
    #   +initialize_grid+ method). Parameter <tt>:assoc</tt> (association) allows to specify another joined table. Presence of
    #   this parameter
    #   * adds sorting capabilities by this field
    #   * automatically creates a filter based on the type of the field unless parameter <tt>:filter</tt> is set to false.
    #     The following filters exist for the following types:
    #     * <tt>string</tt> - a text field
    #     * <tt>integer</tt> and <tt>float</tt>  - two text fields to specify the range. Both limits or only one
    #       can be specified
    #     * <tt>boolean</tt> - a dropdown list with 'yes', 'no', or '-'. These labels can be changed in
    #       <tt>lib/wice_grid_config.rb</tt>.
    #     * <tt>date</tt> - two sets of standard date dropdown lists so specify the time range.
    #     * <tt>datetime</tt> - two sets of standard datetime dropdown lists so specify the time range. This filter
    #       is far from being user-friendly due to the number of dropdown lists.
    # * <tt>:filter</tt> - Disables filters when set to false.
    #   This is needed if sorting is required while  filters are not.
    # * <tt>:filter_type</tt> - Using a column filter different from the default filter chosen automatically based on the
    #   data type or the <tt>:custom_filter</tt> argument. See <tt>lib/columns/column_processor_index.rb</tt> for the
    #   list of available filters.
    # * <tt>:ordering</tt> - Enable/disable ordering links in the column titles. The default is +true+
    #   (i.e. if <tt>:attribute</tt> is defined, ordering is enabled)
    # * <tt>:assoc</tt> - Name of the model association. <tt>:attribute</tt> belongs to the table joined via this association.
    # * <tt>:table_alias</tt> - In case there are two joined assocations both referring to the same table, ActiveRecord
    #   constructs a query where the second join provides an alias for the joined table. Setting <tt>:table_alias</tt>
    #   to this alias will enable WiceGrid to order and filter by columns belonging to different associatiations  but
    #   originating from the same table without confusion. See README for an example.
    # * <tt>:custom_filter</tt> - Allows to construct a custom dropdown filter. Depending on the value of
    #   <tt>:custom_filter</tt> different modes are available:
    #   * array of strings and/or numbers - this is a direct  definition of possible values of the dropdown.
    #     Every item will be used both as the value of the select option and as its label.
    #   * Array of two-element arrays - Every first item of the two-element array is used for the label of the select option
    #     while the second element is the value of the select option
    #   * Hash - The keys of the hash become the labels of the generated dropdown list,
    #     while the values will be values of options of the dropdown list:
    #   * <tt>:auto</tt> - a powerful option which populates the dropdown list with all unique values of the field specified by
    #     <tt>:attribute</tt> and <tt>:model</tt>.
    #     <tt>:attribute</tt> throughout all pages. In other words, this runs an SQL query without +offset+ and +limit+
    #     clauses and  with <tt>distinct(table.field)</tt> instead of <tt>distinct(*)</tt>
    #   * any other symbol name (method name) - The dropdown list is populated by all unique value returned by the
    #     method with this name sent to <em>all</em> ActiveRecord objects throughout all pages. The main difference
    #     from <tt>:auto</tt> is that this method does not have to be a field in the result set, it is just some
    #     value computed in the method after the database call and ActiveRecord instantiation.
    #
    #     But here lies the major drawback - this mode requires additional query without +offset+ and +limit+
    #     clauses to instantiate _all_ ActiveRecord objects, and performance-wise it brings all the advantages
    #     of pagination to nothing. Thus, memory- and performance-wise this can be really bad for some queries
    #     and tables and should be used with care.
    #
    #     If the method returns a atomic value like a string or an integer, it is used for both the value and the
    #     label of the select option element. However, if the retuned value is a two element array, the first element
    #     is used for the option label and the second - for the value.
    #     Read more in README, section 'Custom dropdown filters'
    #   * An array of symbols (method names) - similar to the mode with a single symbol name. The first method name
    #     is sent to the ActiveRecord object if it responds to this method, the second method name is sent to the
    #     returned value unless it is +nil+, and so on. In other words, a single symbol mode is a
    #     case of an array of symbols where the array contains just one element. Thus the warning about the single method name
    #     mode applies here as well.
    #
    #     If the last method returns a atomic value like a string or an integer, it is used for both the value and the
    #     label of the select option element.
    #     However, if the retuned value is a two element array, the first element is used for the option label and the
    #     second - for the value.
    #     Read more in README, section 'Custom dropdown filters'
    # * <tt>:boolean_filter_true_label</tt> - overrides the label for <tt>true</tt> in the boolean filter (<tt>wice_grid.boolean_filter_true_label</tt> in <tt>wice_grid.yml</tt>).
    # * <tt>:boolean_filter_false_label</tt> - overrides the label for <tt>false</tt> in the boolean filter (<tt>wice_grid.boolean_filter_false_label</tt> in <tt>wice_grid.yml</tt>).
    # * <tt>:allow_multiple_selection</tt> - enables or disables switching between single and multiple selection modes for
    #   custom dropdown boxes. +true+ by default (see +ALLOW_MULTIPLE_SELECTION+ in the configuration file).
    # * <tt>:filter_all_label</tt> - overrides the default value for <tt>BOOLEAN_FILTER_FALSE_LABEL</tt> ('<tt>--</tt>')
    #   in the config. Has effect in a column with a boolean filter _or_ a custom filter.
    # * <tt>:detach_with_id</tt> - allows to detach the filter and render it after or before the grid with the
    #   +grid_filter+ helper. The value is an arbitrary unique identifier
    #   of the filter. Read section 'Detached Filters' in README for details.
    #   Has effect in a column with a boolean filter _or_ a custom filter.
    # * <tt>:in_csv</tt> - When CSV export is enabled, all columns are included into the export. Setting <tt>:in_csv</tt>
    #   to false will prohibit the column from inclusion into the export.
    # * <tt>:in_html</tt> - When CSV export is enabled and it is needed to use a column for CSV export only and ignore it
    #   in HTML, set this parameter to false.
    # * <tt>:helper_style</tt> - Changes the flavor of Date and DateTime filters. The values are:
    #   * <tt>:standard</tt> - the default Rails Date/DateTime helper
    #   * <tt>:calendar</tt> - a Javascript popup calendar control
    # * <tt>:negation</tt> - turn on/off the negation checkbox in string filters
    # * <tt>:auto_reload</tt> - a boolean value specifying if a change in a filter triggers reloading of the grid. Works with all
    #   filter types including the JS calendar, the only exception is the standard Rails date/datetime filters.
    #   The default is false. (see +AUTO_RELOAD+ in the configuration file).
    #
    # The block parameter is an ActiveRecord instance. This block is called for every ActiveRecord shown, and the return
    # value of the block is a string which becomes the contents of one table cell, or an array of two elements where
    # the first element is the cell contents and the second is a hash of HTML attributes to be added for the <tt><td></tt>
    # tag of the current cell.
    #
    # In case of an array output, please note that if you need to define HTML attributes for all <tt><td></tt>'s in a
    # column, use +html+. Also note that if the method returns a hash with a <tt>:class</tt> or <tt>'class'</tt>
    # element, it will not overwrite the class defined in +html+, or classes added by the grid itself
    # (+active-filter+ and +sorted+), instead they will be all concatenated:
    # <tt><td class="sorted user_class_for_columns user_class_for_this_specific_cell"></tt>
    #
    # It is up to the developer to make sure that what in rendered in column cells
    # corresponds to sorting and filtering specified by parameters <tt>:attribute</tt> and <tt>:model</tt>.

    def column(opts = {}, &block)
      options = {
        allow_multiple_selection:    Defaults::ALLOW_MULTIPLE_SELECTION,
        assoc:                       nil,
        attribute:                   nil,
        auto_reload:                 Defaults::AUTO_RELOAD,
        boolean_filter_false_label:  NlMessage['boolean_filter_false_label'],
        boolean_filter_true_label:   NlMessage['boolean_filter_true_label'],
        class:                       nil,
        custom_filter:               nil,
        detach_with_id:              nil,
        filter:                      true,
        filter_all_label:            Defaults::CUSTOM_FILTER_ALL_LABEL,
        filter_type:                 nil,
        helper_style:                Defaults::HELPER_STYLE,
        html:                        {},
        in_csv:                      true,
        in_html:                     true,
        name:                        '',
        negation:                    Defaults::NEGATION_IN_STRING_FILTERS,
        ordering:                    true,
        table_alias:                 nil
      }

      opts.assert_valid_keys(options.keys)
      options.merge!(opts)

      assocs = nil

      unless options[:assoc].nil?

        unless options[:assoc].is_a?(Symbol) ||
              (options[:assoc].is_a?(Array) && ! options[:assoc].empty? && options[:assoc].all?{ |assoc| assoc.is_a?(Symbol)} )

          fail WiceGridArgumentError.new('Option :assoc can only be a symbol or an array of symbols')
        end

        assocs = options[:assoc].is_a?(Symbol) ? [options[:assoc]] : options[:assoc]

        options[:model] = get_model_from_associations(@grid.klass, assocs)
      end

      if options[:attribute].nil? && options[:model]
        fail WiceGridArgumentError.new('Option :assoc is only used together with :attribute')
      end

      if options[:attribute] && options[:attribute].index('.')
        fail WiceGridArgumentError.new("Invalid attribute name #{options[:attribute]}. An attribute name must not contain a table name!")
      end

      if options[:class]
        options[:html] ||= {}
        Wice::WgHash.add_or_append_class_value!(options[:html], options[:class])
        options.delete(:class)
      end

      if block.nil?
        if !options[:attribute].blank?
          if assocs.nil?
            block = ->(obj) { obj.send(options[:attribute]) }
          else
            messages = assocs + [ options[:attribute] ]
            block = ->(obj) { obj.deep_send(*messages) }
          end
        else
          fail WiceGridArgumentError.new(
            'Missing column block without attribute defined. You can only omit the block if attribute is present.')
        end
      end

      klass = Columns::ViewColumn
      if options[:attribute] &&
         col_type_and_table_name = @grid.declare_column(
          column_name:          options[:attribute],
          model:                options[:model],
          custom_filter_active: options[:custom_filter],
          table_alias:          options[:table_alias],
          filter_type:          options[:filter_type],
          assocs:               assocs
        )

        # [ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter::Column, String, Boolean]
        db_column, table_name, main_table = col_type_and_table_name
        col_type = db_column.type

        if options[:custom_filter]

          custom_filter = if options[:custom_filter] == :auto
            -> { @grid.distinct_values_for_column(db_column) } # Thank God Ruby has higher order functions!!!

          elsif options[:custom_filter].class == Symbol
            -> { @grid.distinct_values_for_column_in_resultset([options[:custom_filter]]) }

          elsif options[:custom_filter].class == Hash
            options[:custom_filter].keys

            options[:custom_filter].to_a

          elsif options[:custom_filter].class == Array
            if options[:custom_filter].empty?
              []
            elsif Wice::WgEnumerable.all_items_are_of_class(options[:custom_filter], Symbol)
              -> { @grid.distinct_values_for_column_in_resultset(options[:custom_filter]) }

            elsif Wice::WgEnumerable.all_items_are_of_class(options[:custom_filter], String) || WgEnumerable.all_items_are_of_class(options[:custom_filter], Numeric)
              options[:custom_filter].map { |i| [i, i] }

            elsif Wice::WgEnumerable.all_items_are_of_class(options[:custom_filter], Array)
              options[:custom_filter]
            else
              fail WiceGridArgumentError.new(
                ':custom_filter can equal :auto, an array of string and/or numbers (direct values for the dropdown), ' \
                'a homogeneous array of symbols (a sequence of methods to send to AR objects in the result set to ' \
                'retrieve unique values for the dropdown), a Symbol (a shortcut for a one member array of symbols), ' \
                'a hash where keys are labels and values are values for the dropdown option, or an array of two-item arrays, ' \
                'each of which contains the label (first element) and the value (second element) for a dropdown option'
                )
            end
          end

          klass = Columns.get_view_column_processor(:custom)
        elsif options[:filter_type]
          klass = Columns.get_view_column_processor(options[:filter_type])
        else
          klass = Columns.get_view_column_processor(col_type)
        end # custom_filter

      end # attribute

      vc = klass.new(block, options, @grid, table_name, main_table, custom_filter, @view)

      vc.negation = options[:negation] if vc.respond_to? :negation=

      vc.filter_all_label = options[:filter_all_label] if vc.is_a?(Columns.get_view_column_processor(:custom))
      if vc.is_a?(Columns.get_view_column_processor(:boolean))
        vc.boolean_filter_true_label = options[:boolean_filter_true_label]
        vc.boolean_filter_false_label = options[:boolean_filter_false_label]
      end
      add_column(vc)
    end

    def get_model_from_associations(model, assocs)
      if assocs.empty?
        model
      else
        head = assocs[0]
        tail = assocs[1..-1]

        if reflection = model.reflect_on_association(head)
          next_model = reflection.klass
          get_model_from_associations(next_model, tail)
        else
          fail WiceGridArgumentError.new("Association #{head} not found in #{model}")
        end
      end
    end

    # Optional method inside the +grid+ block, to which every ActiveRecord instance is injected, just like +column+.
    # Unlike +column+, it returns a hash which will be used as HTML attributes for the row with the given ActiveRecord instance.
    #
    # Note that if the method returns a hash with a <tt>:class</tt> or <tt>'class'</tt> element, it will not overwrite
    # classes +even+ and +odd+, instead they will be concatenated: <tt><tr class="even highlighted_row_class_name"></tt>
    def row_attributes(&block)
      @row_attributes_handler = block
    end

    # Can be used to add HTML code (another row, for example) right after each grid row.
    # Nothing is added if the block return +false+ or +nil+.
    def after_row(&block)
      @after_row_handler = block
    end

    # Can be used to add HTML code (another row, for example) right before each grid row.
    # Nothing is added if the block return +false+ or +nil+.
    def before_row(&block)
      @before_row_handler = block
    end

    # Can be used to replace the HTML code (for example to make a multi-column spanning row) of a row.
    # Nothing is replaced if the block return +false+ or +nil+.
    def replace_row(&block)
      @replace_row_handler = block
    end

    # Can be used to add HTML code (calculation results, for example) after all rows.
    # Nothing is added if the block return +false+ or +nil+.
    def last_row(&block)
      @last_row_handler = block
    end
    # The output of the block submitted to +blank_slate+ is rendered instead of the whole grid if no filters are active
    # and there are no records to render.
    # In addition to the block style two other variants are accepted:
    # *   <tt>g.blank_slate "some text to be rendered"</tt>
    # *   <tt>g.blank_slate partial: "partial_name"</tt>
    def blank_slate(opts = nil, &block)
      if (opts.is_a?(Hash) && opts.key?(:partial) && block.nil?) || (opts.is_a?(String) && block.nil?)
        @blank_slate_handler = opts
      elsif opts.nil? && block
        @blank_slate_handler = block
      else
        fail WiceGridArgumentError.new("blank_slate accepts only a string, a block, or template: 'path_to_template' ")
      end
    end

    def get_row_attributes(ar_object) #:nodoc:
      if @row_attributes_handler
        row_attributes = @row_attributes_handler.call(ar_object)
        row_attributes = {} if row_attributes.blank?
        unless row_attributes.is_a?(Hash)
          fail WiceGridArgumentError.new("row_attributes block must return a hash containing HTML attributes. The returned value is #{row_attributes.inspect}")
        end
        row_attributes
      else
        {}
      end
    end

    def no_filter_needed?   #:nodoc:
      !@columns.inject(false) { |a, b| a || b.filter_shown? }
    end

    def no_filter_needed_in_main_table?   #:nodoc:
      !@columns.inject(false) { |a, b| a || b.filter_shown_in_main_table? }
    end

    def base_link_for_filter(controller, extra_parameters = {})   #:nodoc:
      new_params = Wice::WgHash.deep_clone controller.params
      new_params.merge!(extra_parameters)

      if new_params[@grid.name]
        new_params[@grid.name].delete(:page) # we reset paging here
        new_params[@grid.name].delete(:f)    # no filter for the base url
        new_params[@grid.name].delete(:foc)  # nullify the focus
        new_params[@grid.name].delete(:q)    # and no request for the saved query
      end

      new_params[:only_path] = false
      base_link_with_pp_info = omit_empty_query controller.url_for(new_params)

      if new_params[@grid.name]
        new_params[@grid.name].delete(:pp)    # and reset back to pagination if show all mode is on
      end
      [base_link_with_pp_info, omit_empty_query(controller.url_for(new_params))]
    end

    def link_for_export(controller, format, extra_parameters = {})   #:nodoc:
      new_params = Wice::WgHash.deep_clone controller.params
      new_params.merge!(extra_parameters)

      new_params[@grid.name] = {} unless new_params[@grid.name]
      new_params[@grid.name][:export] = format

      new_params[:only_path] = false
      controller.url_for(new_params)
    end

    def column_link(column, direction, params, extra_parameters = {})   #:nodoc:
      column_attribute_name = if column.attribute.index('.') || column.main_table
        column.attribute
      else
        column.table_alias_or_table_name + '.' + column.attribute
      end

      query_params = { @grid.name => {
        @@order_parameter_name           => column_attribute_name,
        @@order_direction_parameter_name => direction
      } }

      cleaned_params =  Wice::WgHash.deep_clone params
      cleaned_params.merge!(extra_parameters)

      cleaned_params.delete(:controller)
      cleaned_params.delete(:action)

      query_params = Wice::WgHash.rec_merge(cleaned_params, query_params)

      '?' + query_params.to_query
    end

    protected

    def filter_columns(method_name = nil) #:nodoc:
      method_name ? @columns.select(&method_name) : @columns
    end

    def omit_empty_query(url) #:nodoc:
      # /foo?                --> /foo
      # /foo?grid=           --> /foo
      # /foo?grid=&page=1    --> /foo?page=1
      # /foo?grid=some_value --> /foo?grid=some_value

      empty_hash_rx = Regexp.new "([&?])#{Regexp.escape @grid.name}=([&?]|$)" # c.f., issue #140
      url.gsub(empty_hash_rx, '\1').gsub(/\?+$/, '')
    end
  end
end
