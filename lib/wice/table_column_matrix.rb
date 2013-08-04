# encoding: UTF-8
module Wice
  class TableColumnMatrix < Hash #:nodoc:

    attr_reader :generated_conditions

    def initialize()  #:nodoc:
      super
      @generated_conditions = []
      @by_table_names = HashWithIndifferentAccess.new
    end

    def add_condition(column, conditions)
      @generated_conditions << [column, conditions] unless conditions.blank?
    end

    def conditions
      @generated_conditions.collect{|_, cond| cond}
    end

    alias_method :get, :[]

    attr_reader :default_model_class
    def default_model_class=(model)  #:nodoc:
      init_columns_of_table(model) unless has_key?(model)
      @default_model_class = model
    end

    def [](model)  #:nodoc:
      init_columns_of_table(model) unless has_key?(model)
      get(model)
    end

    def get_column_by_model_class_and_column_name(model_class, column_name)  #:nodoc:
      self[model_class][column_name]
    end

    def get_column_in_default_model_class_by_column_name(column_name)  #:nodoc:
      raise WiceGridException.new("Cannot search for a column in a default model as the default model is not set") if @default_model_class.nil?
      self[@default_model_class][column_name]
    end

    def init_columns_of_table(model) #:nodoc:
      self[model] = HashWithIndifferentAccess.new(model.columns.index_by(&:name))
      @by_table_names[model.table_name] = self[model]
      self[model].each_value{|c| c.model = model}
    end
    alias_method :<< , :init_columns_of_table

  end
end