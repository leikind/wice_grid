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
        hidden_field_tag(param_name, value)
      }.join("\n")
    end

    def dump_state(grid)  #:nodoc:
      debug(grid.get_state_as_parameter_value_pairs)
    end

    # View helper to render the list of saved queries and the form to create a new query.
    # Parameters:
    # * <tt>:extra_parameters</tt> -  a hash of additional parameters to use when creating a new query object.
    # Read section "Adding Application Specific Logic to Saving/Restoring Queries" in README for more details.
    def saved_queries_panel(grid, opts = {})
      unless grid.kind_of? WiceGrid
        raise WiceGridArgumentError.new("saved_queries_panel: the parameter must be a WiceGrid instance.")
      end

      options = {:extra_parameters => {}}
      options.merge!(opts)

      grid_name = grid.name
      id_and_name = "#{grid_name}_saved_query_name"
      base_path_to_query_controller = create_serialized_query_url(:grid_name => grid_name)

      parameters = grid.get_state_as_parameter_value_pairs

      options[:extra_parameters].each do |k, v|
        parameters << [ {:extra => {k => ''}}.to_query.sub(/=$/,'') , v.to_s ]
      end
      parameters <<  ['authenticity_token', form_authenticity_token]
      %! <div class="wice_grid_query_panel"><h3>#{Defaults::SAVED_QUERY_PANEL_TITLE}</h3>! +
        saved_queries_list(grid_name, grid.saved_query, options[:extra_parameters]) +
        %!<div id="#{grid_name}_notification_messages"  onmouseover="new Effect.Fade(this)"></div>! +
        if block_given?
          view, ids = yield
          view
        else
          ''
        end +
        javascript_tag do
          %! 
          function #{grid_name}_save_query(){
            #{grid_name}.save_query($F('#{id_and_name}'), '#{base_path_to_query_controller}', #{parameters.to_json}, #{ids.to_json})
          } !
        end +
        text_field_tag(id_and_name,  '', 
          :size => 20, :onkeydown=>'', :id => id_and_name, 
          :onkeydown=>"if (event.keyCode == 13) {#{grid_name}_save_query()}") +
        button_to_function(Defaults::SAVE_QUERY_BUTTON_LABEL,  "#{grid_name}_save_query()" ) +  '</div>'
        
    end


    def saved_queries_list(grid_name, saved_query = nil, extra_parameters = nil)  #:nodoc:
      query_store_model = ::Wice::get_query_store_model
      currently_loaded_query_id = saved_query ? saved_query.id : nil
      with = extra_parameters.nil? ? nil : "'"  + {:extra => extra_parameters}.to_query + "'"
      
      %!<ul id="#{grid_name}_query_list" class="query_list"> ! +
      query_store_model.list(grid_name, controller).collect do |sq|
        link_opts = {:class => 'query_load_link', :title => "#{Defaults::SAVED_QUERY_LINK_TITLE} #{sq.name}"}
        link_opts[:class] += ' current' if saved_query == sq
        "<li>"+
        link_to_remote(image_tag(Defaults::DELETE_QUERY_ICON),
          {:url => delete_serialized_query_path(:grid_name => grid_name, :id => sq.id, :current => currently_loaded_query_id ),
            :confirm => Defaults::SAVED_QUERY_DELETION_CONFIRMATION, :with => with},
          {:title => "#{Defaults::SAVED_QUERY_DELETION_LINK_TITLE} #{sq.name}"} )  + ' &nbsp; ' +
        link_to_function(h(sq.name), "#{grid_name}.load_query(#{sq.id})", link_opts) + 
        if sq.respond_to? :description
          desc = sq.description 
          desc.blank? ? '' : " <i>#{desc}</i>"
        else
          ''
        end +
        '</li>'
      end.join('') + '</ul>'
    end    


    # View helper for rendering the grid.
    #
    # The first parameter is a grid object returned by +initialize_grid+ in the controller.
    #
    # The second parameter is a hash of options:
    # * <tt>:table_html_attrs</tt> - a hash of HTML attributes to be included into the <tt>table</tt> tag.
    # * <tt>:header_tr_html_attrs</tt> - a hash of HTML attributes to be included into the first <tt>tr</tt> tag
    #   (or two first <tt>tr</tt>'s if the filter row is present).
    # * <tt>:show_filters</tt> - defines when the filter is shown. Possible values are:
    #   * <tt>:when_filtered</tt> - the filter is shown when the current table is the result of filtering
    #   * <tt>:always</tt>        - show the filter always
    #   * <tt>:no</tt>            - never show the filter
    # * <tt>:upper_pagination_panel</tt> - a boolean value which defines whether there is an additional pagination
    #   panel on top of the table. By default it is false.
    # * <tt>:extra_request_parameters</tt> - a hash which will be added as additional HTTP request parameters to all links generated by the grid,
    #   be it sorting links, filters, or the 'Reset Filter' icon. Please note that WiceGrid respects and retains all request parameters already
    #   present in the URL which formed the page, so there is no need to enumerate them in <tt>:extra_request_parameters</tt>. A typical
    #   usage of <tt>:extra_request_parameters</tt> is a page with javascript tabs - changing the active tab does not reload the page, but if
    #   one such tab contains a WiceGrid, it could be required that if the user orders or filters the grid, the result page should have the tab
    #   with the grid activated. For this we need to send an additional parameter specifying from which tab the request was generated.
    # * <tt>:sorting_dependant_row_cycling</tt> - When set to true (by default it is false) the row styles +odd+ and +even+ will be changed
    #   only when the content of the cell belonging to the sorted column changes. In other words, rows with identical values in the ordered
    #   column will have the same style (color).
    # * <tt>:erb_mode</tt> - can be <tt>true</tt> or <tt>false</tt>. Defines the style of the helper method in the view. The default is <tt>false</tt>.
    #   Please read README for more insights.    
    #
    # The block contains definitions of grid columns using the +column+ method sent to the object yielded into the block. In other words,
    # the value returned by each of the blocks defines the content of a cell, the first block is called for cells of the first column
    # for each row (each ActiveRecord instance), the second block is called for cells of the second column, and so on. See the example:
    #
    #   <%= grid(@accounts_grid, :table_html_attrs => {:class => 'grid_style', :id => 'accounts_grid'}, :header_tr_html_attrs => {:class => 'grid_headers'}) do |g|
    #
    #     g.column :column_name => 'Username', :attribute_name => 'username' do |account|
    #       account.username
    #     end
    #
    #     g.column :column_name => 'application_account.field.identity_id'._, :attribute_name => 'firstname', :model_class =>  Person do |account|
    #       link_to(account.identity.name, identity_path(account.identity))
    #     end
    #
    #     g.column do |account|
    #       link_to('Edit', edit_account_path(account))
    #     end
    #
    #   end -%>
    #
    # The helper may have two styles defined by the +erb_mode+ parameter to the +initialize_grid+ in the contoller.
    # By default (<tt>erb_mode = false</tt>) this is a simple helper surrounded by <tt><%=</tt> and <tt>%></tt>:
    #
    #     <%= grid(@countries_grid) do |g|
    #
    #       g.column :column_name => 'Name', :attribute_name => 'name' do |country|
    #         link_to(country.name, country_path(country))
    #       end
    #
    #       g.column :column_name => 'Numeric Code', :attribute_name => 'numeric_code' do |country|
    #         country.numeric_code
    #       end
    #
    #     end -%>
    #
    #
    #
    # The second style (<tt>erb_mode = true</tt>) is called <em>ERB mode</em> and it allows to embed any ERB content inside blocks,
    # which is basically the style of the
    # <tt>form_for</tt> helper, only <tt>form_for</tt> takes one block, while inside the <tt>grid</tt> block there are other method calls taking
    # blocks as parameters:
    #
    #     <% grid(@countries_grid) do |g|
    #
    #       <% g.column :column_name => 'Name', :attribute_name => 'name' do |country| %>
    #         <b>Name: <%= link_to(country.name, country_path(country)) %></b>
    #       <% end %>
    #
    #       <% g.column :column_name => 'Numeric Code', :attribute_name => 'numeric_code' do |country| %>
    #         <i>Numeric Code: <%= country.numeric_code %></i>
    #       <% end %>
    #
    #     <% end -%>
    #
    # This mode can be usable if you like to have much HTML code inside cells.
    #
    # Please remember that in this mode the helper opens with <tt><%</tt> instead of <tt><%=</tt>, similar to <tt>form_for</tt>.
    #
    # Defaults for parameters <tt>:show_filters</tt> and <tt>:upper_pagination_panel</tt>
    # can be changed in <tt>lib/wice_grid_config.rb</tt> using constants <tt>Wice::Defaults::SHOW_FILTER</tt> and
    # <tt>WiceGrid::Defaults::SHOW_UPPER_PAGINATION_PANEL</tt>, this is convenient if you want to set a project wide setting
    # without having to repeat it for every grid instance.
    #
    # Pease read documentation about the +column+ method to achieve the enlightenment.

    def grid(grid, opts = {}, &block)
      raise WiceGridArgumentError.new("The first argument for the grid helper must be an instance of the WiceGrid class") unless grid.class == WiceGrid

      
      if grid.output_buffer
        if grid.output_buffer == true
          raise  WiceGridException.new("Second occurence of grid helper with the same grid object. Did you intend to use detached filters and forget to define them?")
        else
          return grid.output_buffer 
        end
      end

      table_html_attrs = {:class => "wice_grid"}
      header_tr_html_attrs = {}

      Wice.deprecated_call(:table_html_opts, :table_html_attrs, opts)
      Wice.deprecated_call(:header_tr_html_opts, :header_tr_html_attrs, opts)

      if opts[:table_html_attrs]
        table_html_attrs.merge!(opts[:table_html_attrs])
        opts.delete(:table_html_attrs)
      end

      if  opts[:header_tr_html_attrs]
        header_tr_html_attrs.merge!(opts[:header_tr_html_attrs])
        opts.delete(:table_html_attrs)
      end

      options = {
        :show_filters => Defaults::SHOW_FILTER,
        :upper_pagination_panel => Defaults::SHOW_UPPER_PAGINATION_PANEL,
        :sorting_dependant_row_cycling => false,
        :erb_mode => Defaults::ERB_MODE,
        :hide_submit_button => false,
        :hide_reset_button => false,
        :extra_request_parameters => {}}
        
      options.merge!(opts)

      rendering = GridRenderer.new(grid)
      rendering.erb_mode = options[:erb_mode]

      block.call(rendering) # calling block containing column() calls

      if grid.output_csv?
        content = grid_csv(grid, rendering)
      else
        content = grid_html(grid, table_html_attrs, header_tr_html_attrs, options, rendering)
      end

      if grid.after
        lazy_grid_caller = lambda{grid.send(:resultset_without_paging_with_user_filters)}
        if grid.after.is_a?(Proc)
          grid.after.call(lazy_grid_caller)
        elsif grid.after.is_a?(Symbol)
          controller.send(grid.after, lazy_grid_caller)
        end
      end

      if rendering.erb_mode
        # true in this case is a sign that grid_html has run in a normal mode, i.e. wuthout detached filters
        if grid.output_buffer.nil? || grid.output_buffer == true
          return concat(content, block.binding)
        else
          # this way we're sending an empty string and setting flag stubborn_output_mode of GridOutputBuffer to false
          return grid.output_buffer.to_s
        end
      else
        return content
      end
    end

    # secret but stupid weapon
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

    def call_block_as_erb_or_ruby(rendering, block, ar)  #:nodoc:
      if rendering.erb_mode
        capture(ar, &block)
      else
        block.call(ar)
      end
    end    

    def grid_html(grid, table_html_attrs, header_tr_html_attrs, options, rendering) #:nodoc:

      cycle_class = nil
      sorting_dependant_row_cycling = options[:sorting_dependant_row_cycling]

      content = GridOutputBuffer.new
      
      if ENV['RAILS_ENV'] == 'development'
        content << javascript_tag( %$ if (typeof(WiceGridProcessor) == "undefined"){
          alert("wice_grid.js not loaded, WiceGrid cannot proceed! Please make sure that you include Prototype and WiceGrid javascripts in your page. Use <%= include_wice_grid_assets %> or <%= include_wice_grid_assets(:include_calendar => true) %> for WiceGrid javascripts and assets.")
        } else {
          if ((typeof(WiceGridProcessor._version) == "undefined") || ( WiceGridProcessor._version != "0.3.1")) {
            alert("wice_grid.js in your /public is outdated, please run\\n rake wice_grid:copy_resources_to_public\\nto update it.");
          }
        } 
        $ )
      end
      
      content << %!<div class="wice_grid_container"><h3 id="#{grid.name}_title">!
      content << h(grid.saved_query.name) if grid.saved_query
      content << "</h3><table #{tag_options(table_html_attrs, true)}>"


      no_filters_at_all = (options[:show_filters] == :no || rendering.no_filter_needed?) ? true: false
      
      if no_filters_at_all
        no_rightmost_column = no_filter_row = no_filters_at_all
      else
        no_rightmost_column = no_filter_row = (options[:show_filters] == :no || rendering.no_filter_needed_in_main_table?) ? true: false
      end
      
      if options[:upper_pagination_panel]
        content << rendering.pagination_panel(no_rightmost_column){ pagination_panel_content(grid, options[:extra_request_parameters]) }
      end

      content << %!<tr class="wice_grid_title_row" #{tag_options(header_tr_html_attrs, true)}>!

      # first row of column labels with sorting links
      rendering.each_column(:in_html) do |column|
        if column.attribute_name

          css_class = grid.filtered_by?(column) ? 'active_filter' : nil

          direction = 'asc'
          link_style = nil
          if grid.ordered_by?(column)
            css_class = css_class.nil? ? 'sorted' : css_class + ' sorted'
            link_style = grid.order_direction
            direction = 'desc' if grid.order_direction == 'asc'
          end

          col_link = link_to(
            column.column_name,
            rendering.column_link(column, direction, params, options[:extra_request_parameters]),
            :class => link_style)
          content << content_tag(:th, col_link, Hash.make_hash(:class, css_class))
          column.css_class = css_class
        else
          content << content_tag(:th, column.column_name)
        end
      end
      # rendering first row end

      filter_shown = if options[:show_filters] == :when_filtered
        grid.filtering_on?
      elsif options[:show_filters] == :always
        true
      end

      no_filter_opening_closing_icon = (options[:show_filters] == :always) || no_filter_row

      styles = ["display: block;", "display: none;"]
      styles.reverse! unless filter_shown
      hide_icon_id = grid.name + '_hide_icon'
      show_icon_id = grid.name + '_show_icon'
      filter_row_id = grid.name + '_filter_row'

      if no_filter_opening_closing_icon
        hide_icon = show_icon = ''
      else
        hide_icon = content_tag(:span,
          link_to_function(
            image_tag(Defaults::SHOW_HIDE_FILTER_ICON,
              :title => Defaults::HIDE_FILTER_TOOLTIP,
              :alt => Defaults::HIDE_FILTER_TOOLTIP),
            "Element.toggle('#{show_icon_id}'); Element.toggle('#{hide_icon_id}'); "  +
              visual_effect(:fade, filter_row_id, :duration => 0.5, :queue => 'front') ),
          :id => hide_icon_id,
          :style => styles[0]
        )

        show_icon = content_tag(:span,
          link_to_function(
            image_tag(Defaults::SHOW_HIDE_FILTER_ICON,
              :title => Defaults::SHOW_FILTER_TOOLTIP,
              :alt => Defaults::SHOW_FILTER_TOOLTIP),
            "Element.toggle('#{show_icon_id}'); Element.toggle('#{hide_icon_id}'); " +
              visual_effect(:appear, filter_row_id, :duration => 0.5, :queue => 'front') ),
          :id => show_icon_id,
          :style => styles[1]
        )

      end
      content << content_tag(:th, hide_icon + show_icon) unless no_rightmost_column
      content << '</tr>'


      unless no_filters_at_all # there are filters, we don't know where, in the table or detached
        if no_filter_row # they are all detached
          content.stubborn_output_mode = true
          rendering.each_column(:in_html) do |column|
            if column.filter_shown?
              content.add_filter(column.detach_with_id, column.render_filter)
            end
          end
          
        else # some filters are present in the table
          content << %!<tr class="wice_grid_filter_row" id="#{filter_row_id}"!
          content << 'style="display:none"' unless filter_shown
          content << '>'

          rendering.each_column(:in_html) do |column|
            if column.filter_shown?
              if column.detach_with_id
                content.stubborn_output_mode = true
                content << content_tag(:th, '', Hash.make_hash(:class, column.css_class))
                content.add_filter(column.detach_with_id, column.render_filter)
              else
                content << content_tag(:th, column.render_filter, Hash.make_hash(:class, column.css_class))
              end
            else
              content << content_tag(:th, '', Hash.make_hash(:class, column.css_class))
            end
          end

          content << content_tag(:th,
              if options[:hide_submit_button] 
                ''
              else
                link_to_function(image_tag(Defaults::FILTER_ICON, :title => Defaults::FILTER_TOOLTIP,
                  :alt => Defaults::FILTER_TOOLTIP),submit_grid_javascript(grid))
              end + ' ' +
              if options[:hide_reset_button]
                ''
              else
                link_to_function(image_tag(Defaults::RESET_ICON, :title => Defaults::RESET_FILTER_TOOLTIP,
                  :alt => Defaults::RESET_FILTER_TOOLTIP), reset_grid_javascript(grid))
              end
            )
          content << '</tr>'
        end
      end

      rendering.each_column(:in_html) do |column|
        unless column.css_class.blank?
          column.td_html_attrs.add_or_append_class_value(column.css_class)
        end
      end

      # rendering  rows
      cell_value_of_the_ordered_column = nil
      previous_cell_value_of_the_ordered_column = nil
      grid.each do |ar| # rows

        before_row_output = if rendering.before_row_handler
          call_block_as_erb_or_ruby(rendering, rendering.before_row_handler, ar)           
        else
          nil
        end

        after_row_output = if rendering.after_row_handler
          call_block_as_erb_or_ruby(rendering, rendering.after_row_handler, ar)
        else
          nil
        end

        row_content = ''
        rendering.each_column(:in_html) do |column|
          cell_block = column.cell_rendering_block

          opts = column.td_html_attrs.clone
          column_block_output = call_block_as_erb_or_ruby(rendering, cell_block, ar)
          
          if column_block_output.kind_of?(Array)

            unless column_block_output.size == 2
              raise WiceGridArgumentError.new("When WiceGrid column block returns an array it is expected to contain 2 elements only - the first is the contents of the table cell and the second is a hash containing HTML attributes for the <td> tag.")
            end

            column_block_output, additional_opts = column_block_output

            unless additional_opts.is_a?(Hash)
              raise WiceGridArgumentError.new("When WiceGrid column block returns an array its second element is expected to be a hash containing HTML attributes for the <td> tag. The returned value is #{additional_opts.inspect}. Read documentation.")
            end

            additional_css_class = nil
            if additional_opts.has_key?(:class)
              additional_css_class = additional_opts[:class]
              additional_opts.delete(:class)
            elsif additional_opts.has_key?('class')
              additional_css_class = additional_opts['class']
              additional_opts.delete('class')
            end
            opts.merge!(additional_opts)
            opts.add_or_append_class_value(additional_css_class) unless additional_css_class.blank?
          end

          if sorting_dependant_row_cycling && column.attribute_name && grid.ordered_by?(column)
            cell_value_of_the_ordered_column = column_block_output
          end
          row_content += content_tag(:td, column_block_output, opts)
        end

        row_attributes = rendering.get_row_attributes(ar)

        if sorting_dependant_row_cycling
          cycle_class = cycle('odd', 'even', :name => grid.name) if cell_value_of_the_ordered_column != previous_cell_value_of_the_ordered_column
          previous_cell_value_of_the_ordered_column = cell_value_of_the_ordered_column
        else
          cycle_class = cycle('odd', 'even', :name => grid.name)
        end

        row_attributes.add_or_append_class_value(cycle_class)


        content << before_row_output if before_row_output
        content << "<tr #{tag_options(row_attributes)}>#{row_content}"
        content << content_tag(:td, '') unless no_rightmost_column
        content << after_row_output if after_row_output        
        content << '</tr>'
      end

      content << rendering.pagination_panel(no_rightmost_column){ pagination_panel_content(grid, options[:extra_request_parameters]) }
      content << '</table></div>'

      base_link_for_filter, base_link_for_show_all_records = rendering.base_link_for_filter(controller, options[:extra_request_parameters])
      
      link_for_export      = rendering.link_for_export(controller, 'csv', options[:extra_request_parameters])

      parameter_name_for_query_loading = {grid.name => {:q => ''}}.to_query

      content << javascript_tag(
        "#{grid.name} = new WiceGridProcessor('#{grid.name}', '#{base_link_for_filter}', '#{base_link_for_show_all_records}', '#{link_for_export}', '#{parameter_name_for_query_loading}', '#{ENV['RAILS_ENV']}');\n" +
        rendering.select_for(:in_html){|vc|vc.attribute_name and not vc.no_filter}.collect{|column|  column.yield_javascript}.join("\n")
      )
      
      if content.stubborn_output_mode
        grid.output_buffer = content
      else
        # this will serve as a flag that the grid helper has already processed the grid but in a normal mode, 
        # not in the mode with detached filters.
        grid.output_buffer = true
      end
      return content
    end
    
    
    
    # Renders a detached filter. The parameters are:
    # * +grid+ the WiceGrid object
    # * +filter_key+ an identifier of the filter specified in the column declaration by parameter +:detach_with_id+
    def grid_filter(grid, filter_key)
      unless grid.kind_of? WiceGrid
        raise WiceGridArgumentError.new("submit_grid_javascript: the parameter must be a WiceGrid instance.")
      end
      if grid.output_buffer.nil?
        raise WiceGridArgumentError.new("grid_filter: You have attempted to run 'grid_filter' before 'grid'. Read about detached filters in the documentation.")
      end
      if grid.output_buffer == true
        raise WiceGridArgumentError.new("grid_filter: You have defined no detached filters. Read about detached filters in the documentation.")
      end
      
      grid.output_buffer.filter_for filter_key
    end

    # Returns javascript which applies current filters. The parameter is a WiceGrid instance. Use it with +button_to_function+ to create
    # your Submit button.
    def submit_grid_javascript(grid)
      unless grid.kind_of? WiceGrid
        raise WiceGridArgumentError.new("submit_grid_javascript: the parameter must be a WiceGrid instance.")
      end      
      "#{grid.name}.process()"
    end

    # Returns javascript which resets the grid, clearing the state of filters. 
    # The parameter is a WiceGrid instance. Use it with +button_to_function+ to create
    # your Reset button.    
    def reset_grid_javascript(grid)
      unless grid.kind_of? WiceGrid
        raise WiceGridArgumentError.new("reset_grid_javascript: the parameter must be a WiceGrid instance.")
      end      
      "#{grid.name}.reset()"
    end


    def grid_csv(grid, rendering) #:nodoc:


      field_separator = (grid.export_to_csv_enabled && grid.export_to_csv_enabled.is_a?(String)) ? grid.export_to_csv_enabled : ','
      spreadsheet = Spreadsheet.new(grid.name, field_separator)

      # columns
      spreadsheet << rendering.column_labels(:in_csv)

      # rendering  rows
      grid.each do |ar| # rows
        row = []

        rendering.each_column(:in_csv) do |column|
          cell_block = column.cell_rendering_block

          column_block_output = call_block_as_erb_or_ruby(rendering, cell_block, ar)
          
          if column_block_output.kind_of?(Array)
            column_block_output, additional_opts = column_block_output
          end

          row << column_block_output
        end
        spreadsheet << row
      end
      spreadsheet.close
      return spreadsheet.path
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
      opts.merge!(options)
      
      if @__wice_grid_on_page || ! opts[:load_on_demand]
        javascript_include_tag('wice_grid') +
        stylesheet_link_tag('wice_grid') +
        if opts[:include_calendar]
          stylesheet_link_tag(File.join(Defaults::DYNARCH_CALENDAR_ASSETS_PATH,  "calendar-#{Defaults::DYNARCH_CALENDAR_STYLE}.css")) +
          javascript_include_tag(File.join(Defaults::DYNARCH_CALENDAR_ASSETS_PATH,  "calendar.js")) +
          javascript_include_tag(File.join(Defaults::DYNARCH_CALENDAR_ASSETS_PATH,  "lang/calendar-#{Defaults::DYNARCH_CALENDAR_LANG}.js")) +
          javascript_include_tag(File.join(Defaults::DYNARCH_CALENDAR_ASSETS_PATH,  "calendar-setup.js"))
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
      opts.merge!(options)
      res = ['wice_grid']
      if opts[:include_calendar]
        res += [ File.join(Defaults::DYNARCH_CALENDAR_ASSETS_PATH,  "calendar.js"),
          File.join(Defaults::DYNARCH_CALENDAR_ASSETS_PATH,  "lang/calendar-#{Defaults::DYNARCH_CALENDAR_LANG}.js"),
          File.join(Defaults::DYNARCH_CALENDAR_ASSETS_PATH,  "calendar-setup.js") ]
      end
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
      opts.merge!(options)
      res = ['wice_grid']
      res += [File.join(Defaults::DYNARCH_CALENDAR_ASSETS_PATH,  "calendar-#{Defaults::DYNARCH_CALENDAR_STYLE}.css")] if opts[:include_calendar]
      res
    end



    def pagination_panel_content(grid, extra_request_parameters) #:nodoc:
      extra_request_parameters = extra_request_parameters.clone
      if grid.saved_query
        extra_request_parameters["#{grid.name}[q]"] = grid.saved_query.id
      end

      will_paginate(grid.resultset, :previous_label => Defaults::PREVIOUS_LABEL, :next_label => Defaults::NEXT_LABEL,
      :param_name => "#{grid.name}[page]", :params => extra_request_parameters).to_s +
      ' <div class="pagination_status">' + pagination_info(grid) + '</div>'
    end


    def show_all_link(collection_total_entries, parameters, grid_name) #:nodoc:
      confirmation = collection_total_entries > Defaults::START_SHOWING_WARNING_FROM ? "if (confirm('#{Defaults::ALL_QUERIES_WARNING}'))" : ''
      '<span class="show_all_link">' +
        link_to_function(Defaults::SHOW_ALL_RECORDS_LABEL, 
        "#{confirmation} #{grid_name}.reload_page_for_given_grid_state(#{parameters.to_json})",
        :title => Defaults::SHOW_ALL_RECORDS_TOOLTIP) + '</span>'      
    end
    
    def back_to_pagination_link(parameters, grid_name) #:nodoc:
      pagination_override_parameter_name = "#{grid_name}[pp]"
      parameters = parameters.reject{|k, v| k == pagination_override_parameter_name}
      ' <span class="show_all_link">' + 
        link_to_function(Defaults::SWITCH_BACK_TO_PAGINATED_MODE_LABEL, 
          "#{grid_name}.reload_page_for_given_grid_state(#{parameters.to_json})",
          :tooltip => Defaults::SWITCH_BACK_TO_PAGINATED_MODE_TOOLTIP) +
        '</span>'
    end

    def pagination_info(grid, options = {})  #:nodoc:
      collection = grid.resultset
      if (collection.total_pages < 2 && collection.length == 0)
        '0'
      else
        collection_total_entries = collection.total_entries
        collection_total_entries_str = collection_total_entries.to_s
        parameters = grid.get_state_as_parameter_value_pairs
        parameters << ["#{grid.name}[pp]", collection_total_entries_str]

        "#{collection.offset + 1}-#{collection.offset + collection.length} / #{collection_total_entries_str} " +
          if (! grid.allow_showing_all_records?) || collection_total_entries <= collection.length
            ''
          else
            show_all_link(collection_total_entries, parameters, grid.name)
          end
      end + 
      if grid.all_record_mode?
        back_to_pagination_link(parameters, grid.name)
      else
        ''
      end
    end
  end
end