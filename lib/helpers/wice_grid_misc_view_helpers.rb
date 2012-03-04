# encoding: UTF-8
module Wice
  module GridViewHelper


    # This method dumps all HTTP parameters related to filtering and ordering of a certain grid as hidden form fields.
    # This might be required if you want to keep the state of a grid while reloading the page using other forms.
    #
    # The only parameter is a grid object returned by +initialize_grid+ in the controller.
    def dump_filter_parameters_as_hidden_fields(grid)
      unless grid.kind_of? WiceGrid
        raise WiceGridArgumentError.new("dump_filter_parameters_as_hidden_fields: the parameter must be a WiceGrid instance.")
      end

      grid.get_state_as_parameter_value_pairs(true).collect{|param_name, value|
        hidden_field_tag(param_name, value, :id => "hidden-#{param_name.gsub(/[\[\]]/, '-')}")
      }.join("\n").html_safe_if_necessary
    end

    def dump_state(grid)  #:nodoc:
      debug(grid.get_state_as_parameter_value_pairs)
    end


    # secret but stupid weapon - takes an ActiveRecord and using reflection tries to build all the column clauses by itself.
    # WiceGrid is not a scaffolding solution, I hate scaffolding and how certain idiots associate scaffolding with Rails,
    # so I do not document this method to avoid contributing to this misunderstanding.
    def scaffolded_grid(grid_obj, opts = {}) #:nodoc:
      Wice::JsAdaptor.init
      unless grid_obj.kind_of? WiceGrid
        raise WiceGridArgumentError.new("scaffolded_grid: the parameter must be a WiceGrid instance.")
      end

      # debug grid.klass.column_names
      columns = grid_obj.klass.column_names
      if opts[:reject_attributes].is_a? Proc
        columns = columns.reject{|c| opts[:reject_attributes].call(c)}
        opts.delete(:reject_attributes)
      elsif
        columns = columns.reject{|c| c =~ opts[:reject_attributes]}
        opts.delete(:reject_attributes)
      end
      grid(grid_obj, opts) do |g|
        columns.each do |column_name|
          g.column :column_name => column_name.humanize, :attribute_name => column_name  do |ar|
            ar.send(column_name)
          end
        end
      end
    end

  end
end