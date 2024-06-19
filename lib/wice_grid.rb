require 'wice/wice_grid_misc.rb'
require 'wice/wice_grid_core_ext.rb'
require 'wice/grid_renderer.rb'
require 'wice/table_column_matrix.rb'
require 'wice/active_record_column_wrapper.rb'
require 'wice/helpers/wice_grid_view_helpers.rb'
require 'wice/helpers/wice_grid_misc_view_helpers.rb'
require 'wice/helpers/wice_grid_serialized_queries_view_helpers.rb'
require 'wice/helpers/wice_grid_view_helpers.rb'
require 'wice/helpers/bs_calendar_helpers.rb'
require 'wice/helpers/js_calendar_helpers.rb'
require 'wice/grid_output_buffer.rb'
require 'wice/wice_grid_controller.rb'
require 'wice/wice_grid_spreadsheet.rb'
require 'wice/wice_grid_serialized_queries_controller.rb'
require 'wice/columns/column_processor_index.rb'
require 'wice/columns.rb'
require 'wice/columns/common_date_datetime_mixin.rb'
require 'wice/columns/common_standard_helper_date_datetime_mixin.rb'
require 'wice/columns/common_js_date_datetime_mixin.rb'
require 'wice/columns/common_js_date_datetime_conditions_generator_mixin.rb'
require 'wice/columns/common_rails_date_datetime_conditions_generator_mixin.rb'
require 'kaminari.rb'


ActionController::Base.send(:helper_method, :wice_grid_custom_filter_params)

module Wice

  def self.on_action_view_load #:nodoc:
    ::ActionView::Base.class_eval { include Wice::GridViewHelper }
    [ActionView::Helpers::AssetTagHelper,
     ActionView::Helpers::TagHelper,
     ActionView::Helpers::JavaScriptHelper,
     ActionView::Helpers::FormTagHelper].each do |m|
      JsCalendarHelpers.send(:include, m)
    end

    Columns.load_column_processors
    require 'wice/wice_grid_serialized_query.rb'

    # It is here only because of this: https://github.com/amatsuda/kaminari/pull/267
    require 'wice/kaminari_monkey_patching.rb'

  end

  class WiceGridEngine < ::Rails::Engine #:nodoc:
    initializer 'wice_grid_railtie.configure_rails_initialization' do |_app|
      ActiveSupport.on_load :action_controller do
        ActionController::Base.send(:include, Wice::Controller)
      end

      ActiveSupport.on_load :active_record do
        ActiveRecord::ConnectionAdapters::Column.send(:include, ::Wice::WiceGridExtentionToActiveRecordColumn)
      end

      ActiveSupport.on_load :action_view do
        ::Wice.on_action_view_load
      end
    end

    initializer 'wice_grid_railtie.configure_rails_assets_precompilation' do |app|
      app.config.assets.precompile << 'icons/grid/*'
    end
  end


  # Main class responsible for keeping the state of the grid, building an ActiveRelation, and running queries
  class WiceGrid
    attr_reader :klass, :name, :resultset, :custom_order, :query_store_model #:nodoc:
    attr_reader :ar_options, :status, :export_to_csv_enabled, :csv_file_name, :csv_field_separator, :csv_encoding, :saved_query #:nodoc:
    attr_writer :renderer #:nodoc:
    attr_accessor :output_buffer, :view_helper_finished, :csv_tempfile #:nodoc:

    # core workflow methods START

    def initialize(klass_or_relation, controller, opts = {})  #:nodoc:
      @controller = controller

      @relation = klass_or_relation
      @klass = if @relation.is_a?(Class) && @relation.ancestors.index(ActiveRecord::Base)
        klass_or_relation
      else
        klass_or_relation.klass
      end

      unless @klass.is_a?(Class) && @klass.ancestors.index(ActiveRecord::Base)
        raise WiceGridArgumentError.new('ActiveRecord model class (second argument) must be a Class derived from ActiveRecord::Base')
      end

      # validate :with_resultset & :with_paginated_resultset
      [:with_resultset, :with_paginated_resultset].each do |callback_symbol|
        unless [NilClass, Symbol, Proc].index(opts[callback_symbol].class)
          raise WiceGridArgumentError.new(":#{callback_symbol} must be either a Proc or Symbol object")
        end
      end

      opts[:order_direction] = opts[:order_direction].downcase if opts[:order_direction].is_a?(String)

      # validate :order_direction
      if opts[:order_direction] && ! (opts[:order_direction] == 'asc' || opts[:order_direction] == :asc || opts[:order_direction] == 'desc' ||
                                      opts[:order_direction] == :desc)
        raise WiceGridArgumentError.new(":order_direction must be either 'asc' or 'desc'.")
      end

      begin
        # options that are understood
        @options = {
          conditions:                 nil,
          csv_file_name:              nil,
          csv_field_separator: ConfigurationProvider.value_for(:CSV_FIELD_SEPARATOR),
          csv_encoding:               ConfigurationProvider.value_for(:CSV_ENCODING),
          custom_order:               {},
          enable_export_to_csv: ConfigurationProvider.value_for(:ENABLE_EXPORT_TO_CSV),
          group:                      nil,
          include:                    nil,
          joins:                      nil,
          name:                       ConfigurationProvider.value_for(:GRID_NAME),
          order:                      nil,
          order_direction:            ConfigurationProvider.value_for(:ORDER_DIRECTION),
          page:                       1,
          page_method_name:           ConfigurationProvider.value_for(:PAGE_METHOD_NAME),
          per_page:                   ConfigurationProvider.value_for(:PER_PAGE),
          saved_query:                nil,
          with_paginated_resultset:   nil,
          with_resultset:             nil,
          use_default_scope:          ConfigurationProvider.value_for(:USE_DEFAULT_SCOPE)
        }
      rescue NameError
        raise NameError.new('A constant is missing in wice_grid_config.rb: ' + $ERROR_INFO.message +
          '. This can happen when you upgrade the WiceGrid to a newer version with a new configuration constant. ' \
          'Add the constant manually or re-run `bundle exec rails g wice_grid:install`.')
      end
      # validate parameters
      opts.assert_valid_keys(@options.keys)

      @options.merge!(opts)
      @export_to_csv_enabled = @options[:enable_export_to_csv]
      @csv_file_name = @options[:csv_file_name]
      @csv_field_separator = @options[:csv_field_separator]
      @csv_encoding = @options[:csv_encoding]

      case @name = @options[:name]
      when String
      when Symbol
        @name = @name.to_s
      else
        raise WiceGridArgumentError.new('name of the grid should be a string or a symbol')
      end
      raise WiceGridArgumentError.new('name of the grid can only contain alphanumeruc characters') unless @name =~ /^[a-zA-Z\d_]*$/

      @table_column_matrix = TableColumnMatrix.new
      @table_column_matrix.default_model_class = @klass

      @ar_options = {}
      @status = HashWithIndifferentAccess.new

      if @options[:order]
        @options[:order]           = @options[:order].to_s
        @options[:order_direction] = @options[:order_direction].to_s

        @status[:order_direction]  = @options[:order_direction]
        @status[:order]            = @options[:order]

      end
      @status[:per_page]      = @options[:per_page]
      @status[:page]          = @options[:page]
      @status[:conditions]    = @options[:conditions]
      @status[:f]             = @options[:f]

      process_loading_query
      process_params

      @ar_options_formed = false
    end

    # A block executed from within the plugin to process records of the current page.
    # The argument to the callback is the array of the records. See the README for more details.
    def with_paginated_resultset(&callback)
      @options[:with_paginated_resultset] = callback
    end

    # A block executed from within the plugin to process all records browsable through
    # all pages with the current filters. The argument to
    # the callback is a lambda object which returns the list of records when called. See the README for the explanation.
    def with_resultset(&callback)
      @options[:with_resultset] = callback
    end

    def process_loading_query #:nodoc:
      @saved_query = nil
      if params[name] && params[name][:q]
        @saved_query = load_query(params[name][:q])
        params[name].delete(:q)
      elsif @options[:saved_query]
        if @options[:saved_query].is_a? ActiveRecord::Base
          @saved_query = @options[:saved_query]
        else
          @saved_query = load_query(@options[:saved_query])
        end
      else
        return
      end

      unless @saved_query.nil?
        params[name] = HashWithIndifferentAccess.new if params[name].blank?
        [:f, :order, :order_direction].each do |key|
          if @saved_query.query[key].blank?
            params[name].delete(key)
          else
            params[name][key] = @saved_query.query[key]
          end
        end
      end
    end

    def process_params  #:nodoc:
      if this_grid_params
        @status.merge!(this_grid_params)
        @status.delete(:export) unless self.export_to_csv_enabled
      end
    end

    # declare_column(String, ActiveRecord, CustomFilterSpec, nil | string, nil | Boolean)
    def declare_column(
                 column_name: nil,
                 model: nil,
                 custom_filter_active: nil,
                 table_alias: nil,
                 filter_type: nil,
                 assocs: [],
                 sort_by: nil)  #:nodoc:


      @options[:include] = Wice.build_includes(@options[:include], assocs)

      if model # this is an included table
        column = @table_column_matrix.get_column_by_model_class_and_column_name(model, column_name)
        raise WiceGridArgumentError.new("Column '#{column_name}' is not found in table '#{model.table_name}'!") if column.nil?
        main_table = false
        table_name = model.table_name
      else
        column = @table_column_matrix.get_column_in_default_model_class_by_column_name(column_name)
        # Allow the column to not exist if we're doing a custom sort (calculated field)
        if column.nil? && !sort_by
          raise WiceGridArgumentError.new("Column '#{column_name}' is not found in table '#{@klass.table_name}'! " \
            "If '#{column_name}' belongs to another table you should declare it in :include or :join when initialising " \
            'the grid, and specify :model in column declaration.')
        end
        main_table = true
        table_name = @table_column_matrix.default_model_class.table_name
      end

      if column
        conditions_generator = ActiveRecordColumnWrapper.new(column, @status[:f], main_table, table_alias, custom_filter_active, filter_type)
        conditions, current_parameter_name = conditions_generator.wg_initialize_request_parameters

        if @status[:f] && conditions.blank?
          @status[:f].delete(current_parameter_name)
        end

        @table_column_matrix.add_condition(column, conditions)

        # [ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter::Column, String, Boolean]
        [column, table_name, main_table]
      end
    end

    def form_ar_options(opts = {})  #:nodoc:
      return if @ar_options_formed
      @ar_options_formed = true unless opts[:forget_generated_options]

      # validate @status[:order_direction]
      @status[:order_direction] = case @status[:order_direction]
      when /desc/i
        'desc'
      when /asc/i
        'asc'
      else
        ''
      end

      # conditions
      # do not delete for a while
      # https://github.com/leikind/wice_grid/issues/144
      # if @table_column_matrix.generated_conditions.size == 0
      #   @status.delete(:f)
      # end

      initial_conditions_active_relation = @klass.where(@status[:conditions])

      @ar_options[:conditions] =
        @table_column_matrix.conditions.reduce(initial_conditions_active_relation) do |active_relation_accu, cond|
          conditions_active_relation = @klass.where(cond)
          active_relation_accu.merge(conditions_active_relation)
        end

      # conditions processed

      if (!opts[:skip_ordering]) && ! @status[:order].blank?
        custom_order = get_custom_order_reference
        if custom_order
          @ar_options[:order] = custom_order
        else
          @ar_options[:order] = arel_column_reference(@status[:order])
        end
        if @ar_options[:order].is_a?(Arel::Attributes::Attribute) || @ar_options[:order].is_a?(Arel::Nodes::SqlLiteral)
          if @status[:order_direction] == 'desc'
            @ar_options[:order] = @ar_options[:order].desc
          else
            @ar_options[:order] = @ar_options[:order].asc
          end
        else
          @ar_options[:order] += " #{@status[:order_direction]}"
        end
      end

      @ar_options[:joins]   = @options[:joins]
      @ar_options[:include] = @options[:include]
      @ar_options[:group]   = @options[:group]

      if self.output_html?
        @ar_options[:per_page]      = @status[:per_page]
        @ar_options[:page]          = @status[:page]

        if (show_all_limit = Wice::ConfigurationProvider.value_for(:SHOW_ALL_ALLOWED_UP_TO, strict: false)) && all_record_mode?
          if do_count > show_all_limit # force-reset SHOW-ALL to pagination
            @status[:pp] = nil
          end
        end

      end
    end

    def add_references(relation) #:nodoc:
      if @ar_options[:include] && relation.respond_to?(:references)
        # refs = [@ar_options[:include]] unless @ar_options[:include].is_a?(Array)
        relation = relation.references(* @ar_options[:include])
      end
      relation
    end

    # Apply the sort_by option to the results.
    def apply_sort_by(relation)
      active_sort_by = nil
      @renderer.find_one_for(->(c) {c.attribute == @status[:order]}) {|r| active_sort_by = r.sort_by}
      return relation if !active_sort_by
      relation = relation.sort_by(&active_sort_by)
      relation = relation.reverse if @status[:order_direction] == 'desc'
      return relation
    end

    # TO DO: what to do with other @ar_options values?
    def read  #:nodoc:
      form_ar_options
      use_default_or_unscoped do
        relation = @relation
                       .includes(@ar_options[:include])
                       .joins(@ar_options[:joins])
                       .group(@ar_options[:group])
                       .merge(@ar_options[:conditions])
        relation = add_references relation
        relation = apply_sort_by relation

        # If relation is an Array, it got the sort from apply_sort_by.
        if @ar_options[:order].is_a? String
          @ar_options[:order] = Arel.sql @ar_options[:order]
        end
        relation = relation.order(@ar_options[:order]) if !relation.is_a?(Array)

        if !output_csv? && !all_record_mode?
          if relation.is_a?(Array)
            relation = Kaminari.paginate_array(relation, limit: @ar_options[:per_page], offset: @ar_options[:per_page].to_i * (@ar_options[:page].to_i - 1))
          else
            relation = relation
                           .send(@options[:page_method_name], @ar_options[:page])
                           .per(@ar_options[:per_page])
          end
        end

        if all_record_mode? && relation.is_a?(Array)
          # This still needs to be a Kaminari object as the paginator will read limit_value.
          relation = Kaminari.paginate_array(relation, limit: relation.count)
        end

        @resultset = relation
      end

      invoke_resultset_callbacks
    end

    # core workflow methods END

    # Getters

    def filter_params(view_column)  #:nodoc:
      column_name = view_column.attribute_name_fully_qualified_for_all_but_main_table_columns
      if @status[:f] && @status[:f][column_name]
        @status[:f][column_name]
      else
        {}
      end
    end

    def resultset  #:nodoc:
      self.read unless @resultset # database querying is late!
      @resultset
    end

    def each   #:nodoc:
      self.read unless @resultset # database querying is late!
      @resultset.each do |r|
        yield r
      end
    end

    # Returns true if the current results are ordered by the passed column.
    def ordered_by?(column)
      return nil if @status[:order].blank?
      if column.main_table && ! @status[:order].index('.') || column.table_alias_or_table_name.nil?
        @status[:order] == column.attribute
      else
        @status[:order] == column.table_alias_or_table_name + '.' + column.attribute
      end
    end

    def ordered_by  #:nodoc:
      @status[:order]
    end

    def order_direction  #:nodoc:
      @status[:order_direction]
    end

    def filtering_on?  #:nodoc:
      !@status[:f].blank?
    end

    def filtered_by  #:nodoc:
      @status[:f].nil? ? [] : @status[:f].keys
    end

    def filtered_by?(view_column)  #:nodoc:
      @status[:f].nil? ? false : @status[:f].key?(view_column.attribute_name_fully_qualified_for_all_but_main_table_columns)
    end

    def get_state_as_parameter_value_pairs(including_saved_query_request = false) #:nodoc:
      res = []
      unless status[:f].blank?
        Wice::WgHash.parameter_names_and_values(status[:f], [name, 'f']).collect do |param_name, value|
          if value.is_a?(Array)
            param_name_ar = param_name + '[]'
            value.each do |v|
              res << [param_name_ar, v]
            end
          else
            res << [param_name, value]
          end
        end
      end

      if including_saved_query_request && @saved_query
        res << ["#{name}[q]", @saved_query.id]
      end

      [:order, :order_direction].select do|parameter|
        status[parameter]
      end.collect do |parameter|
        res << ["#{name}[#{parameter}]", status[parameter]]
      end

      res
    end

    def count  #:nodoc:
      form_ar_options(skip_ordering: true, forget_generated_options: true)
      do_count
    end

    def do_count #:nodoc:
      @relation
        .all
        .joins(@ar_options[:joins])
        .includes(@ar_options[:include])
        .group(@ar_options[:group])
        .where(@options[:conditions])
        .count
    end

    alias_method :size, :count

    def empty?  #:nodoc:
      self.count == 0
    end

    # with this variant we get even those values which do not appear in the resultset
    def distinct_values_for_column(column)  #:nodoc:
      column.model.select("distinct #{column.name}").order("#{column.name} asc").collect do|ar|
        ar[column.name]
      end.reject(&:blank?).map { |i| [i, i] }
    end

    def distinct_values_for_column_in_resultset(messages)  #:nodoc:
      uniq_vals = Set.new

      resultset_without_paging_without_user_filters.each do |ar|
        v = ar.deep_send(*messages)
        uniq_vals << v unless v.nil?
      end
      uniq_vals.to_a.map do|i|
        if i.is_a?(Array) && i.size == 2
          i
        elsif i.is_a?(Hash) && i.size == 1
          i.to_a.flatten
        else
          [i, i]
        end
      end.sort { |a, b| a[0] <=> b[0] }
    end

    def output_csv? #:nodoc:
      @status[:export] == 'csv'
    end

    def output_html? #:nodoc:
      @status[:export].blank?
    end

    def all_record_mode? #:nodoc:
      @status[:pp]
    end

    def dump_status #:nodoc:
      "   params: #{params[name].inspect}\n" + "   status: #{@status.inspect}\n" \
        "   ar_options #{@ar_options.inspect}\n"
    end

    # Returns the list of objects browsable through all pages with the current filters.
    # Should only be called after the +grid+ helper.
    def all_pages_records
      raise WiceGridException.new('all_pages_records can only be called only after the grid view helper') unless self.view_helper_finished
      resultset_without_paging_with_user_filters
    end

    # Returns the list of objects displayed on current page. Should only be called after the +grid+ helper.
    def current_page_records
      raise WiceGridException.new('current_page_records can only be called only after the grid view helper') unless self.view_helper_finished
      @resultset
    end

    protected

    def invoke_resultset_callback(callback, argument) #:nodoc:
      case callback
      when Proc
        callback.call(argument)
      when Symbol
        @controller.send(callback, argument)
      end
    end

    def invoke_resultset_callbacks #:nodoc:
      invoke_resultset_callback(@options[:with_paginated_resultset], @resultset)
      invoke_resultset_callback(@options[:with_resultset], self.active_relation_for_resultset_without_paging_with_user_filters)
    end

    # If a custom order has been configured, gets the column/function to be ordered by. If no custom order, returns nil.
    def get_custom_order_reference
      # TODO Do we need to distinguish between no custom order and a custom order that defines no ordering? Both return nil.

      fully_qualified_column_name = complete_column_name(@status[:order])
      custom_order = if @options[:custom_order].key?(fully_qualified_column_name)
        @options[:custom_order][fully_qualified_column_name]
      else
        if view_column = @renderer[fully_qualified_column_name]
          view_column.custom_order
        end
      end

      return custom_order if custom_order.nil? || custom_order.is_a?(Arel::Attributes::Attribute)
      return custom_order.gsub(/\?/, fully_qualified_column_name) if custom_order.is_a?(String)
      return custom_order.call(fully_qualified_column_name) if custom_order.is_a?(Proc)
      raise WiceGridArgumentError.new("invalid custom order #{custom_order.inspect}")
    end

    # Returns an Arel::Attributes::Attribute for the passed column reference.
    def arel_column_reference(col_name)  #:nodoc:
      if col_name.index('.') # already has a table name
        table_name, col_name = col_name.split('.', 2)
        Arel::Table.new(table_name)[col_name]
      else # add the default table
        @klass.arel_table[col_name]
      end
    end

    # Returns tablename.columnname for the passed column reference.
    def complete_column_name(col_name)
      return col_name if col_name.index('.') # already has a table name
      return "#{@klass.table_name}.#{col_name}"
    end

    def params  #:nodoc:
      @controller.params
    end

    def this_grid_params  #:nodoc:
      params[name].try(:to_unsafe_h) || params[name]
    end

    def resultset_without_paging_without_user_filters  #:nodoc:
      form_ar_options

      use_default_or_unscoped do
        relation = @relation.joins(@ar_options[:joins])
                   .includes(@ar_options[:include])
                   .group(@ar_options[:group])
                   .where(@options[:conditions])

        relation = add_references relation

        relation
      end
    end

    # not used right now
    # def count_resultset_without_paging_without_user_filters  #:nodoc:
    #   form_ar_options
    #   @klass.unscoped do
    #     @relation.count(
    #       joins:      @ar_options[:joins],
    #       include:    @ar_options[:include],
    #       group:      @ar_options[:group],
    #       conditions: @options[:conditions]
    #     )
    #   end
    # end

    def resultset_without_paging_with_user_filters  #:nodoc:
      active_relation_for_resultset_without_paging_with_user_filters.to_a
    end

    def active_relation_for_resultset_without_paging_with_user_filters  #:nodoc:
      form_ar_options
      relation = nil

      use_default_or_unscoped do
        if @ar_options[:order].is_a? String
          @ar_options[:order] = Arel.sql @ar_options[:order]
        end
        relation = @relation
                   .joins(@ar_options[:joins])
                   .includes(@ar_options[:include])
                   .order(@ar_options[:order])
                   .merge(@ar_options[:conditions])

        relation = add_references relation
      end
      relation
    end

    def load_query(query_id) #:nodoc:
      @query_store_model ||= Wice.get_query_store_model
      query = @query_store_model.find_by_id_and_grid_name(query_id, self.name)
      Wice.log("Query with id #{query_id} for grid '#{self.name}' not found!!!") if query.nil?
      query
    end

    def use_default_or_unscoped #:nodoc:
      if @options[:use_default_scope]
        yield
      else
        @klass.unscoped { yield }
      end
    end

  end

  # routines called from WiceGridExtentionToActiveRecordColumn (ActiveRecord::ConnectionAdapters::Column) or ConditionsGeneratorColumn classes
  module GridTools   #:nodoc:
    class << self
      def special_value(str)   #:nodoc:
        str =~ /^\s*(not\s+)?null\s*$/i
      end

      # create a Time instance out of parameters
      def params_2_datetime(par)   #:nodoc:
        return nil if par.blank?
        params = [par[:year], par[:month], par[:day], par[:hour], par[:minute]].collect { |v| v.blank? ? nil : v.to_i }
        begin
          Time.local(*params)
        rescue ArgumentError, TypeError
          nil
        end
      end

      # create a Date instance out of parameters
      def params_2_date(par)   #:nodoc:
        return nil if par.blank?
        params = [par[:year], par[:month], par[:day]].collect { |v| v.blank? ? nil : v.to_i }
        begin
          Date.civil(*params)
        rescue ArgumentError, TypeError
          nil
        end
      end
    end
  end
end
