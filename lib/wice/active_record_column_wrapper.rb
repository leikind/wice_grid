module Wice
  # to be mixed in into ActiveRecord::ConnectionAdapters::Column
  module WiceGridExtentionToActiveRecordColumn #:nodoc:
    # reference to the ActiveRecord model class
    attr_accessor :model
  end

  class ActiveRecordColumnWrapper #:nodoc:
    def initialize(column, all_filter_params, main_table, table_alias, custom_filter_active, filter_type) #:nodoc:
      @column = column

      # nil | Symbol
      @filter_type          = filter_type

      # Hash { String => String | Array[String]}
      @all_filter_params    = all_filter_params

      # nil | Boolean
      @main_table           = main_table

      # nil | String
      @table_alias          = table_alias

      # nil | Array[String] | Array[Array[...]] | Array[Symbol]
      @custom_filter_active = custom_filter_active
    end

    def wg_initialize_request_parameters  #:nodoc:
      @request_params = nil
      return if @all_filter_params.nil?

      # if the parameter does not specify the table name we only allow columns in the default table to use these parameters
      if @main_table && @request_params = @all_filter_params[@column.name]
        current_parameter_name = @column.name
      elsif @request_params = @all_filter_params[alias_or_table_name(@table_alias) + '.' + @column.name]
        current_parameter_name = alias_or_table_name(@table_alias) + '.' + @column.name
      end

      # Preprocess incoming parameters for datetime, if what's coming in is
      # a datetime (with custom_filter it can be anything else, and not
      # the datetime hash {fr: ..., to: ...})
      if @request_params

        if (@column.type == :datetime || @column.type == :timestamp) && @request_params.is_a?(Hash)
          [:fr, :to].each do |sym|
            if @request_params[sym]
              if @request_params[sym].is_a?(String)
                @request_params[sym] = Wice::ConfigurationProvider.value_for(:DATETIME_PARSER).call(@request_params[sym])
              elsif @request_params[sym].is_a?(Hash)
                @request_params[sym] = Wice::GridTools.params_2_datetime(@request_params[sym])
              end
            end
          end

        end

        # Preprocess incoming parameters for date, if what's coming in is
        # a date (with custom_filter it can be anything else, and not
        # the date hash {fr: ..., to: ...})
        if @column.type == :date && @request_params.is_a?(Hash)

          [:fr, :to].each do |sym|
            if @request_params[sym]
              if @request_params[sym].is_a?(String)
                @request_params[sym] = Wice::ConfigurationProvider.value_for(:DATE_PARSER).call(@request_params[sym])
              elsif @request_params[sym].is_a?(Hash)
                @request_params[sym] = ::Wice::GridTools.params_2_date(@request_params[sym])
              end
            end
          end

        end
      end

      [wg_generate_conditions, current_parameter_name]
    end

    def wg_generate_conditions  #:nodoc:
      return nil if @request_params.nil?

      if @custom_filter_active
        custom_processor_klass = ::Wice::Columns.get_conditions_generator_column_processor(:custom)
        custom_processor = custom_processor_klass.new(self)
        return custom_processor.generate_conditions(@table_alias, @request_params)
      end

      column_type = @filter_type || @column.type.to_s.intern

      filter_type = case column_type
      when :date
        ConfigurationProvider.value_for(:DEFAULT_FILTER_FOR_DATE)
      when :datetime
        ConfigurationProvider.value_for(:DEFAULT_FILTER_FOR_DATETIME)
      when :timestamp
        ConfigurationProvider.value_for(:DEFAULT_FILTER_FOR_DATETIME)
      else
        column_type
      end

      processor_class = ::Wice::Columns.get_conditions_generator_column_processor(filter_type)

      if processor_class
        return processor_class.new(self, column_type).generate_conditions(@table_alias, @request_params)
      else
        Wice.log("No processor for database type #{column_type}!!!")
        nil
      end
    end

    def name #:nodoc:
      @column.name
    end

    def model #:nodoc:
      @column.model
    end

    def array?
      if @column.sql_type_metadata.respond_to? :array
        @column.sql_type_metadata.array
      else
        @column.sql_type_metadata.sql_type.index('[]')
      end
    rescue
      false
    end

    def alias_or_table_name(table_alias) #:nodoc:
      table_alias || @column.model.table_name
    end
  end
end
