require 'will_paginate.rb'
require 'wice_grid_misc.rb'
require 'helpers/js_calendar_helpers.rb'
require 'wice_grid_core_ext.rb'
require 'grid_renderer.rb'
require 'table_column_matrix.rb'
require 'helpers/wice_grid_view_helpers.rb'
require 'helpers/wice_grid_misc_view_helpers.rb'
require 'helpers/wice_grid_serialized_queries_view_helpers.rb'
require 'view_columns.rb'
require 'grid_output_buffer.rb'
require 'wice_grid_controller.rb'
require 'wice_grid_spreadsheet.rb'
require 'wice_grid_serialized_queries_controller.rb'

module Wice

  class WiceGrid

    attr_reader :klass, :name, :resultset, :custom_order, :after, :query_store_model
    attr_reader :ar_options, :status, :export_to_csv_enabled, :csv_file_name, :saved_query
    attr_writer :renderer
    attr_accessor :output_buffer, :view_helper_finished

    # core workflow methods START

    def initialize(klass, controller, opts = {})  #:nodoc:
      @controller = controller

      # check for will_paginate
      # raise WiceGridException.new("Plugin will_paginate not found! wice_grid requires will_paginate.")
      unless klass.respond_to?(:paginate)
        raise Wice::WiceGridException.new('will_paginate not found, WiceGrid cannot proceed. Please install gem mislav-will_paginate. ' +
                                          'You might need to add github.com as the gem source before you install the gem: ' +
                                          'gem sources -a http://gems.github.com')
      end

      unless klass.kind_of?(Class) && klass.ancestors.index(ActiveRecord::Base)
        raise WiceGridArgumentError.new("ActiveRecord model class (second argument) must be a Class derived from ActiveRecord::Base")
      end

      # validate :after
      unless [NilClass, Symbol, Proc].index(opts[:after].class)
        raise WiceGridArgumentError.new(":after must be either a Proc or Symbol object")
      end

      opts[:order_direction].downcase! if opts[:order_direction].kind_of?(String)

      # validate :order_direction
      if opts[:order_direction] && ! (opts[:order_direction] == 'asc'  ||
                                      opts[:order_direction] == :asc   ||
                                      opts[:order_direction] == 'desc' ||
                                      opts[:order_direction] == :desc)
        raise WiceGridArgumentError.new(":order_direction must be either 'asc' or 'desc'.")
      end

      # options that are understood
      @options = {
        :after                => nil,
        :conditions           => nil,
        :csv_file_name        => nil,
        :custom_order         => {},
        :enable_export_to_csv => Defaults::ENABLE_EXPORT_TO_CSV,
        :include              => nil,
        :joins                => nil,
        :name                 => Defaults::GRID_NAME,
        :order                => nil,
        :order_direction      => Defaults::ORDER_DIRECTION,
        :page                 => 1,
        :per_page             => Defaults::PER_PAGE,
        :saved_query          => nil,
        :total_entries        => nil
      }

      # validate parameters
      opts.assert_valid_keys(@options.keys)

      @options.merge!(opts)
      @export_to_csv_enabled = @options[:enable_export_to_csv]
      @csv_file_name = @options[:csv_file_name]

      @after = @options[:after]

      case @name = @options[:name]
      when String
      when Symbol
        @name = @name.to_s
      else
        raise WiceGridArgumentError.new("name of the grid should be a string or a symbol")
      end
      raise WiceGridArgumentError.new("name of the grid can only contain alphanumeruc characters") unless @name =~ /^[a-zA-Z\d_]*$/

      @klass = klass

      @table_column_matrix = TableColumnMatrix.new
      @table_column_matrix.default_model_class = @klass

      @ar_options = {}
      @status = HashWithIndifferentAccess.new

      if @options[:order]
        @options[:order] = @options[:order].to_s
        @options[:order_direction] = @options[:order_direction].to_s

        @status[:order_direction] = @options[:order_direction]
        @status[:order] = @options[:order]

      end
      @status[:total_entries] = @options[:total_entries]
      @status[:per_page] = @options[:per_page]
      @status[:page] = @options[:page]
      @status[:conditions] = @options[:conditions]
      @status[:f] = @options[:f]

      process_loading_query
      process_params

      @ar_options_formed = false
      
      @method_scoping = @klass.send(:scoped_methods)[-1]
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

    def declare_column(column_name, model_class, custom_filter_active, table_alias)  #:nodoc:
      if model_class # this is an included table
        column = @table_column_matrix.get_column_by_model_class_and_column_name(model_class, column_name)
        raise WiceGridArgumentError.new("Сolumn '#{column_name}' is not found in table '#{model_class.table_name}'!") if column.nil?
        main_table = false
        table_name = model_class.table_name
      else
        column = @table_column_matrix.get_column_in_default_model_class_by_column_name(column_name)
        if column.nil?
          raise WiceGridArgumentError.new("Сolumn '#{column_name}' is not found in table '#{@klass.table_name}'! " +
            "If '#{column_name}' belongs to another table you should declare it in :include or :join when initialising " +
            "the grid, and specify :model_class in column declaration.")
        end
        main_table = true
        table_name = @table_column_matrix.default_model_class.table_name
      end

      if column
        conditions, current_parameter_name = column.wg_initialize_request_parameters(@status[:f], main_table, table_alias, custom_filter_active)
        if @status[:f] && conditions.blank?
          @status[:f].delete(current_parameter_name)
        end

        @table_column_matrix.add_condition(column, conditions)
        [column, table_name , main_table]
      else
        nil
      end
    end

    def form_ar_options(opts = {})  #:nodoc:

      return if @ar_options_formed
      @ar_options_formed = true unless opts[:forget_generated_options]

      # conditions
      if @table_column_matrix.generated_conditions.size == 0
        @status.delete(:f)
      end
      
      @ar_options[:conditions] = klass.merge_conditions(@status[:conditions], * @table_column_matrix.conditions)
      # conditions processed

      if (! opts[:skip_ordering]) && @status[:order]
        @ar_options[:order] = add_custom_order_sql(complete_column_name(@status[:order]))

        @ar_options[:order] += ' ' + @status[:order_direction]
      end

      if self.output_html?
        @ar_options[:per_page] = @status[:pp] || @status[:per_page]
        @ar_options[:page] = @status[:page]
        @ar_options[:total_entries] = @status[:total_entries] if @status[:total_entries]
      end

      @ar_options[:joins]   = @options[:joins]
      @ar_options[:include] = @options[:include]
    end

    def read  #:nodoc:
      form_ar_options
      with_exclusive_scope do
        @resultset = self.output_csv? ?  @klass.find(:all, @ar_options) : @klass.paginate(@ar_options)
      end
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

    def ordered_by?(column)  #:nodoc:
      return nil if @status[:order].blank?
      if column.main_table && ! offs = @status[:order].index('.')
        @status[:order] == column.attribute_name
      else
        @status[:order] == column.table_alias_or_table_name + '.' + column.attribute_name
      end
    end

    def ordered_by  #:nodoc:
      @status[:order]
    end


    def order_direction  #:nodoc:
      @status[:order_direction]
    end

    def filtering_on?  #:nodoc:
      not @status[:f].blank?
    end

    def filtered_by  #:nodoc:
      @status[:f].nil? ? [] : @status[:f].keys
    end

    def filtered_by?(view_column)  #:nodoc:
      @status[:f].nil? ? false : @status[:f].has_key?(view_column.attribute_name_fully_qualified_for_all_but_main_table_columns)
    end

    def get_state_as_parameter_value_pairs(including_saved_query_request = false) #:nodoc:
      res = []
      unless status[:f].blank?
        status[:f].parameter_names_and_values([name, 'f']).collect do |param_name, value|
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
        res << ["#{name}[q]", @saved_query.id ]
      end

      [:order, :order_direction].select{|parameter|
        status[parameter]
      }.collect do |parameter|
        res << ["#{name}[#{parameter}]", status[parameter] ]
      end

      res
    end

    def count  #:nodoc:
      form_ar_options(:skip_ordering => true, :forget_generated_options => true)
      @klass.count(:conditions => @ar_options[:conditions], :joins => @ar_options[:joins], :include => @ar_options[:include])
    end

    alias_method :size, :count

    def empty?  #:nodoc:
      self.count == 0
    end

    # with this variant we get even those values which do not appear in the resultset
    def distinct_values_for_column(column)  #:nodoc:
      res = column.model_klass.find(:all, :select => 'distinct ' + column.name).collect{|ar| ar[column.name] }.reject(&:blank?).map{|i|[i,i]}
    end


    def distinct_values_for_column_in_resultset(messages)  #:nodoc:
      uniq_vals = Set.new

      resultset_without_paging_without_user_filters.each do |ar|
        v = ar.deep_send(*messages)
        uniq_vals << v unless v.nil?
      end
      return uniq_vals.to_a.map{|i|
        if i.is_a?(Array) && i.size == 2
          i
        elsif i.is_a?(Hash) && i.size == 1
          i.to_a.flatten
        else
          [i,i]
        end
      }
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
      "   params: #{params[name].inspect}\n"  +
      "   status: #{@status.inspect}\n" +
      "   ar_options #{@ar_options.inspect}\n"
    end


    # Returns a list of all records of the current selection throughout all pages.
    # Can be called only after the view helper.
    # See section "Integration With The Application" in the README.
    def selected_records
      raise WiceGridException.new("all_records can only be called only after the grid view helper") unless self.view_helper_finished
      resultset_without_paging_with_user_filters
    end


    protected

    def with_exclusive_scope #:nodoc:
      if @method_scoping
        @klass.send(:with_exclusive_scope, @method_scoping) do
          yield
        end
      else
        yield
      end
    end


    def add_custom_order_sql(fully_qualified_column_name) #:nodoc:
      custom_order = if @options[:custom_order].has_key?(fully_qualified_column_name)
        @options[:custom_order][fully_qualified_column_name]
      else
        if view_column = @renderer[fully_qualified_column_name]
          view_column.custom_order
        else
          nil
        end
      end

      if custom_order.blank?
        fully_qualified_column_name
      else
        if custom_order.is_a? String
          custom_order.gsub(/\?/, fully_qualified_column_name)
        elsif custom_order.is_a? Proc
          custom_order.call(fully_qualified_column_name)
        else
          raise WiceGridArgumentError.new("invalid custom order #{custom_order.inspect}")
        end
      end
    end

    def complete_column_name(col_name)  #:nodoc:
      if col_name.index('.') # already has a table name
        col_name
      else # add the default table
        "#{@klass.table_name}.#{col_name}"
      end
    end

    def params  #:nodoc:
      @controller.params
    end

    def this_grid_params  #:nodoc:
      params[name]
    end


    def resultset_without_paging_without_user_filters  #:nodoc:
      form_ar_options
      with_exclusive_scope do
        @klass.find(:all, :joins => @ar_options[:joins], 
                          :include => @ar_options[:include], 
                          :conditions => @options[:conditions])
      end
    end

    def resultset_without_paging_with_user_filters  #:nodoc:
      form_ar_options
      with_exclusive_scope do
        @klass.find(:all, :joins      => @ar_options[:joins],
                          :include    => @ar_options[:include],
                          :conditions => @ar_options[:conditions],
                          :order      => @ar_options[:order])
      end
    end


    def load_query(query_id) #:nodoc:
      @query_store_model ||= Wice::get_query_store_model
      query = @query_store_model.find_by_id_and_grid_name(query_id, self.name)
      Wice::log("Query with id #{query_id} for grid '#{self.name}' not found!!!") if query.nil?
      query
    end


  end

  # routines called from WiceGridExtentionToActiveRecordColumn (ActiveRecord::ConnectionAdapters::Column) or FilterConditionsGenerator classes
  module GridTools   #:nodoc:
    class << self
      def special_value(str)   #:nodoc:
        str =~ /^\s*(not\s+)?null\s*$/i
      end
    end

    # create a Time instance out of parameters
    def params_2_datetime(par)   #:nodoc:
      return nil if par.blank?
      params =  [par[:year], par[:month], par[:day], par[:hour], par[:minute]].collect{|v| v.blank? ? nil : v.to_i}
      Time.local(*params)
    end

    # create a Date instance out of parameters
    def params_2_date(par)   #:nodoc:
      return nil if par.blank?
      params =  [par[:year], par[:month], par[:day]].collect{|v| v.blank? ? nil : v.to_i}
      Date.civil(*params)
    end
  end

  # to be mixed in into ActiveRecord::ConnectionAdapters::Column
  module WiceGridExtentionToActiveRecordColumn #:nodoc:

    attr_accessor :model_klass

    def alias_or_table_name(table_alias)
      table_alias || self.model_klass.table_name
    end

    def wg_initialize_request_parameters(all_filter_params, main_table, table_alias, custom_filter_active)  #:nodoc:
      @request_params = nil
      return if all_filter_params.nil?

      # if the parameter does not specify the table name we only allow columns in the default table to use these parameters
      if main_table && @request_params  = all_filter_params[self.name]
        current_parameter_name = self.name
      elsif @request_params = all_filter_params[alias_or_table_name(table_alias) + '.' + self.name]
        current_parameter_name = alias_or_table_name(table_alias) + '.' + self.name
      end

      if @request_params
        if self.type == :datetime || self.type == :timestamp
          [:fr, :to].each do |sym|
            if @request_params[sym]
              if @request_params[sym].is_a?(String)
                @request_params[sym] = Wice::Defaults::DATETIME_PARSER.call(@request_params[sym])
              elsif @request_params[sym].is_a?(Hash)
                @request_params[sym] = ::Wice::GridTools.params_2_datetime(@request_params[sym])
              end
            end
          end

        end

        if self.type == :date

          [:fr, :to].each do |sym|
            if @request_params[sym]
              if @request_params[sym].is_a?(String)
                @request_params[sym] = Wice::Defaults::DATE_PARSER.call(@request_params[sym])
              elsif @request_params[sym].is_a?(Hash)
                @request_params[sym] = ::Wice::GridTools.params_2_date(@request_params[sym])
              end
            end
          end
        end
      end

      return wg_generate_conditions(table_alias, custom_filter_active), current_parameter_name
    end

    def wg_generate_conditions(table_alias, custom_filter_active)  #:nodoc:
      return nil if @request_params.nil?

      if custom_filter_active
        return ::Wice::FilterConditionsGeneratorCustomFilter.new(self).generate_conditions(table_alias, @request_params)
      end

      column_type = self.type.to_s

      processor_class = ::Wice::FilterConditionsGenerator.handled_type[column_type]

      if processor_class
        return processor_class.new(self).generate_conditions(table_alias, @request_params)
      else
        Wice.log("No processor for database type #{column_type}!!!")
        nil
      end
    end

  end

  class FilterConditionsGenerator   #:nodoc:

    cattr_accessor :handled_type
    @@handled_type = HashWithIndifferentAccess.new

    def initialize(column)   #:nodoc:
      @column = column
    end
  end

  class FilterConditionsGeneratorCustomFilter < FilterConditionsGenerator #:nodoc:

    def generate_conditions(table_alias, opts)   #:nodoc:
      if opts.empty?
        Wice.log "empty parameters for the grid custom filter"
        return false
      end
      opts = (opts.kind_of?(Array) && opts.size == 1) ? opts[0] : opts

      if opts.kind_of?(Array)
        opts_with_special_values, normal_opts = opts.partition{|v| ::Wice::GridTools.special_value(v)}

        conditions_ar = if normal_opts.size > 0
          [" #{@column.alias_or_table_name(table_alias)}.#{@column.name} IN ( " + (['?'] * normal_opts.size).join(', ') + ' )'] + normal_opts
        else
          []
        end

        if opts_with_special_values.size > 0
          special_conditions = opts_with_special_values.collect{|v| " #{@column.alias_or_table_name(table_alias)}.#{@column.name} is " + v}.join(' or ')
          if conditions_ar.size > 0
            conditions_ar[0] = " (#{conditions_ar[0]} or #{special_conditions} ) "
          else
            conditions_ar = " ( #{special_conditions} ) "
          end
        end
        conditions_ar
      else
        if ::Wice::GridTools.special_value(opts)
          " #{@column.alias_or_table_name(table_alias)}.#{@column.name} is " + opts
        else
          [" #{@column.alias_or_table_name(table_alias)}.#{@column.name} = ?", opts]
        end
      end
    end

  end

  class FilterConditionsGeneratorBoolean < FilterConditionsGenerator  #:nodoc:
    @@handled_type[:boolean] = self

    def  generate_conditions(table_alias, opts)   #:nodoc:
      unless (opts.kind_of?(Array) && opts.size == 1)
        Wice.log "invalid parameters for the grid boolean filter - must be an one item array: #{opts.inspect}"
        return false
      end
      opts = opts[0]
      if opts == 'f'
        [" (#{@column.alias_or_table_name(table_alias)}.#{@column.name} = ? or #{@column.alias_or_table_name(table_alias)}.#{@column.name} is null) ", false]
      elsif opts == 't'
        [" #{@column.alias_or_table_name(table_alias)}.#{@column.name} = ?", true]
      else
        nil
      end
    end
  end

  class FilterConditionsGeneratorString < FilterConditionsGenerator  #:nodoc:
    @@handled_type[:string] = self
    @@handled_type[:text]   = self

    def generate_conditions(table_alias, opts)   #:nodoc:
      if opts.kind_of? String
        string_fragment = opts
        negation = ''
      elsif (opts.kind_of? Hash) && opts.has_key?(:v)
        string_fragment = opts[:v]
        negation = opts[:n] == '1' ? 'NOT' : ''
      else
        Wice.log "invalid parameters for the grid string filter - must be a string: #{opts.inspect} or a Hash with keys :v and :n"
        return false
      end
      if string_fragment.empty?
        Wice.log "invalid parameters for the grid string filter - empty string"
        return false
      end
      [" #{negation}  #{@column.alias_or_table_name(table_alias)}.#{@column.name} #{::Wice.get_string_matching_operators(@column.model_klass)} ?",
          '%' + string_fragment + '%']
    end

  end

  class FilterConditionsGeneratorInteger < FilterConditionsGenerator  #:nodoc:
    @@handled_type[:integer] = self
    @@handled_type[:float]   = self
    @@handled_type[:decimal] = self

    def  generate_conditions(table_alias, opts)   #:nodoc:
      unless opts.kind_of? Hash
        Wice.log "invalid parameters for the grid integer filter - must be a hash"
        return false
      end
      conditions = [[]]
      if opts[:fr]
        if opts[:fr] =~ /\d/
          conditions[0] << " #{@column.alias_or_table_name(table_alias)}.#{@column.name} >= ? "
          conditions << opts[:fr]
        else
          opts.delete(:fr)
        end
      end

      if opts[:to]
        if opts[:to] =~ /\d/
          conditions[0] << " #{@column.alias_or_table_name(table_alias)}.#{@column.name} <= ? "
          conditions << opts[:to]
        else
          opts.delete(:to)
        end
      end

      if conditions.size == 1
        Wice.log "invalid parameters for the grid integer filter - either range limits are not supplied or they are not numeric"
        return false
      end

      conditions[0] = conditions[0].join(' and ')

      return conditions
    end
  end

  class FilterConditionsGeneratorDate < FilterConditionsGenerator  #:nodoc:
    @@handled_type[:date]      = self
    @@handled_type[:datetime]  = self
    @@handled_type[:timestamp] = self

    def generate_conditions(table_alias, opts)   #:nodoc:
      conditions = [[]]
      if opts[:fr]
        conditions[0] << " #{@column.alias_or_table_name(table_alias)}.#{@column.name} >= ? "
        conditions << opts[:fr]
      end

      if opts[:to]
        conditions[0] << " #{@column.alias_or_table_name(table_alias)}.#{@column.name} <= ? "
        conditions << opts[:to]
      end

      return false if conditions.size == 1

      conditions[0] = conditions[0].join(' and ')
      return conditions
    end
  end

end

ActiveRecord::ConnectionAdapters::Column.send(:include, ::Wice::WiceGridExtentionToActiveRecordColumn)
