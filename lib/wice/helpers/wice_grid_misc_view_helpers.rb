# encoding: utf-8
module Wice

  # Various grid related helpers
  module GridViewHelper
    # This method dumps all HTTP parameters related to filtering and ordering of a certain grid as hidden form fields.
    # This might be required if you want to keep the state of a grid while reloading the page using other forms.
    #
    # The only parameter is a grid object returned by +initialize_grid+ in the controller.
    def dump_filter_parameters_as_hidden_fields(grid)
      unless grid.is_a? WiceGrid
        fail WiceGridArgumentError.new('dump_filter_parameters_as_hidden_fields: the parameter must be a WiceGrid instance.')
      end

      grid.get_state_as_parameter_value_pairs(true).collect do|param_name, value|
        hidden_field_tag(param_name, value, id: "hidden-#{param_name.gsub(/[\[\]]/, '-')}")
      end.join("\n").html_safe
    end

    # This method dumps all HTTP parameters related to filtering of a certain grid in the form of a hash.
    # This might be required if you want to keep the state of a grid while reloading the page using Rails routing helpers.
    # Attention: this does not return parameters for ordering the grid, use +filter_and_order_state_as_hash+ if you
    # need it.
    #
    # The only parameter is a grid object returned by +initialize_grid+ in the controller.
    def filter_state_as_hash(grid)
      { grid.name => { 'f' => grid.status[:f] } }
    end

    # This method dumps all HTTP parameters related to filtering and ordering of a certain grid in the form of a hash.
    # This might be required if you want to keep the state of a grid while reloading the page using Rails routing helpers.
    #
    # The only parameter is a grid object returned by +initialize_grid+ in the controller.
    def filter_and_order_state_as_hash(grid)
      {
        grid.name => {
          'f'               => grid.status[:f],
          'order'           => grid.status[:order],
          'order_direction' => grid.status[:order_direction]
        }
      }
    end

    # display the state of the grid
    def dump_state(grid)  #:nodoc:
      debug(grid.get_state_as_parameter_value_pairs)
    end

    # secret but stupid weapon - takes an ActiveRecord and using reflection tries to build all the column clauses by itself.
    # WiceGrid is not a scaffolding solution, I hate scaffolding and how certain idiots associate scaffolding with Rails,
    # so I do not document this method to avoid contributing to this misunderstanding.
    def scaffolded_grid(grid_obj, opts = {}) #:nodoc:
      unless grid_obj.is_a? WiceGrid
        fail WiceGridArgumentError.new('scaffolded_grid: the parameter must be a WiceGrid instance.')
      end

      # debug grid.klass.column_names
      columns = grid_obj.klass.column_names
      if opts[:reject_attributes].is_a? Proc
        columns = columns.reject { |c| opts[:reject_attributes].call(c) }
        opts.delete(:reject_attributes)
      else
        columns = columns.reject { |c| c =~ opts[:reject_attributes] }
        opts.delete(:reject_attributes)
      end
      grid(grid_obj, opts) do |g|
        columns.each do |column_name|
          g.column name: column_name.humanize, attribute: column_name  do |ar|
            ar.send(column_name)
          end
        end
      end
    end
  end
end
