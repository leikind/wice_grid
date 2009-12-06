module Wice
  module GridViewHelper

    # +wice_grid_custom_filter_params+ generates HTTP parameters understood by WiceGrid custom filters.
    # Combined with Rails route helpers it allows to generate links leading to 
    # grids with pre-selected custom filters.
    #
    # Parameters:
    # * <tt>:grid_name</tt> - The name of the grid. Just like parameter <tt>:name</tt> of 
    #   <tt>initialize_grid</tt>, the parameter is optional, and when absent, the name
    #   <tt>'grid'</tt> is assumed
    # * <tt>:attribute_name</tt> and <tt>:model_class</tt> - should be the same as <tt>:attribute_name</tt> and 
    #   <tt>:model_class</tt> of the column declaration with the target custom filter.
    # * <tt>:value</tt> - the value of the column filter.
    def wice_grid_custom_filter_params(opts = {})
      options = {:grid_name => 'grid', 
                 :attribute_name => nil,
                 :model_class => nil,
                 :value => nil}
      options.merge!(opts)

      [:attribute_name, :value].each do |key|
        raise ::Wice::WiceGridArgumentError.new("wice_grid_custom_filter_foo: :#{key} is a mandatory argument") unless options[key]
      end

      attr_name = if options[:model_class]
        unless options[:model_class].nil?
          options[:model_class] = options[:model_class].constantize if options[:model_class].is_a? String
          raise Wice::WiceGridArgumentError.new("Option :model_class can be either a class or a string instance") unless options[:model_class].is_a? Class
        end
        options[:model_class].table_name + '.' + options[:attribute_name]
      else
        options[:attribute_name]
      end

      {"#{options[:grid_name]}[f][#{attr_name}][]" => options[:value]}
    end


    # This method dumps all HTTP parameters related to filtering and ordering of a certain grid as hidden form fields.
    # This might be required if you want to keep the state of a grid while reloading the page using other forms.
    #
    # The only parameter is a grid object returned by +initialize_grid+ in the controller.
    def dump_filter_parameters_as_hidden_fields(grid)
      unless grid.kind_of? WiceGrid
        raise WiceGridArgumentError.new("dump_filter_parameters_as_hidden_fields: the parameter must be a WiceGrid instance.")
      end

      grid.get_state_as_parameter_value_pairs(true).collect{|param_name, value|
        hidden_field_tag(param_name, value)
      }.join("\n")
    end

    def dump_state(grid)  #:nodoc:
      debug(grid.get_state_as_parameter_value_pairs)
    end


    # secret but stupid weapon - takes an ActiveRecord and using reflection tries to build all the column clauses by itself.
    # WiceGrid is not a scaffolding solution, I hate scaffolding and how certain idiots associate scaffolding with Rails,
    # so I do not document this method to avoid contributing to this misunderstanding.
    def scaffolded_grid(grid_obj, opts = {}) #:nodoc:
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

    # View helper to include all stylesheets and javascript files needed for WiceGrid to function. Add it to template/layout in the
    # page header section.
    #
    # By default the helper returns WiceGrid javascripts and stylesheets include statements only on demand, that is, only if at least one initialize_grid has been
    # called in the controller. Otherwise the helper returns an empty string. However, you can force the old unconditioned behavior if you need by submitting
    # parameter <tt>:load_on_demand</tt> set to +false+:
    #     <%= include_wice_grid_assets(:load_on_demand => false) %>
    #
    # By default +include_wice_grid_assets+ adds include statements for the javascript calendar widget used for date/datetime filters,
    # but it's possible not to include them setting parameter +include_calendar+ to false:
    #     <%= include_wice_grid_assets(:include_calendar => false) %>
    def include_wice_grid_assets(options = {})

      opts = {:include_calendar => true, :load_on_demand => true}
      options.assert_valid_keys(opts.keys)
      opts.merge!(options)

      if @__wice_grid_on_page || ! opts[:load_on_demand]
        javascript_include_tag('wice_grid') +
        stylesheet_link_tag('wice_grid') +
        if opts[:include_calendar]
          stylesheet_link_tag("calendarview.css") + javascript_include_tag("calendarview.js")
        else
          ''
        end
      end
    end

    #  Returns a list of names of javascript files for WiceGrid thus providing compatibility with Rails asset caching.
    #  Mind the parameters, and the fact that Prototype has to be loaded before WiceGrid javascripts:
    #
    #    <%= javascript_include_tag *([:defaults] + names_of_wice_grid_javascripts + [ 'ui', 'swfobject', {:cache => true}]) %>
    #
    #  By default +names_of_wice_grid_javascripts+ returns all javascripts, but it's possible not to include calendar widget javascripts by
    #  setting parameter <tt>:include_calendar</tt>  to +false+.
    def names_of_wice_grid_javascripts(options = {})
      opts = {:include_calendar => true}
      options.assert_valid_keys(opts.keys)
      opts.merge!(options)
      res = ['wice_grid']
      res <<  'calendarview.js' if opts[:include_calendar]
      res
    end

    #  Returns a list of names of stylesheet files for WiceGrid thus providing compatibility with Rails asset caching.
    #  Mind the parameters, for example:
    #
    #    <%= stylesheet_link_tag *(['core',  'modalbox'] + names_of_wice_grid_stylesheets + [ {:cache => true}]) %>
    #
    #  By default +names_of_wice_grid_stylesheets+ returns all javascripts, but it's possible not to include calendar widget javascripts by
    #  setting parameter <tt>:include_calendar</tt>  to +false+.
    def names_of_wice_grid_stylesheets(options = {})
      opts = {:include_calendar => true}
      options.assert_valid_keys(opts.keys)
      opts.merge!(options)
      res = ['wice_grid']
      res << "calendarview.css" if opts[:include_calendar]
      res
    end

    if self.respond_to?(:safe_helper)
      safe_helper :wice_grid_custom_filter_params, :dump_filter_parameters_as_hidden_fields, 
        :dump_state, :scaffolded_grid, :include_wice_grid_assets, :names_of_wice_grid_javascripts,
        :names_of_wice_grid_stylesheets
    end
  end
end