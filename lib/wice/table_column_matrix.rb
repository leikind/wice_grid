module Wice

  # a matrix for all declared columns
  class TableColumnMatrix < Hash #:nodoc:

    # a structure to hold generates Arels for all column filters
    attr_reader :generated_conditions

    # init a matrix of all columns
    def initialize  #:nodoc:
      super
      @generated_conditions = []
      @by_table_names = HashWithIndifferentAccess.new
    end

    # add an Arel for a column
    def add_condition(column, conditions)
      @generated_conditions << [column, conditions] unless conditions.blank?
    end

    # returns a list of all Arels
    def conditions
      @generated_conditions.collect { |_, cond| cond }
    end

    # returns Arels for one model
    alias_method :get, :[]

    # returns the main ActiveRecord model class
    attr_reader :default_model_class

    # sets the main ActiveRecord model class
    def default_model_class=(model)  #:nodoc:
      init_columns_of_table(model) unless key?(model)
      @default_model_class = model
    end

    # returns Arels for one model
    def [](model)  #:nodoc:
      init_columns_of_table(model) unless key?(model)
      get(model)
    end

    def get_column_by_model_class_and_column_name(model_class, column_name)  #:nodoc:
      self[model_class][column_name]
    end

    def get_column_in_default_model_class_by_column_name(column_name)  #:nodoc:
      if @default_model_class.nil?
        raise WiceGridException.new("Cannot search for this column(#{column_name}) in a default model(#{@default_model_class}) as the default model is not set")
      end

      self[@default_model_class][column_name]
    end

    def init_columns_of_table(model) #:nodoc:
      self[model] =
          HashWithIndifferentAccess.new(model.columns.map(&:dup).index_by(&:name))
      @by_table_names[model.table_name] = self[model]
      self[model].each_value { |c| c.model = model }
    end

    alias_method :<<, :init_columns_of_table
  end
end
