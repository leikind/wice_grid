# encoding: UTF-8
module Wice
  module GridViewHelper

    # View helper to render the list of saved queries and the form to create a new query.
    # Parameters:
    # * <tt>:extra_parameters</tt> -  a hash of additional parameters to use when creating a new query object.
    # Read section "Adding Application Specific Logic to Saving/Restoring Queries" in README for more details.
    def saved_queries_panel(grid, opts = {})
      unless grid.kind_of? WiceGrid
        raise WiceGridArgumentError.new("saved_queries_panel: the parameter must be a WiceGrid instance.")
      end

      options = {:extra_parameters => {}}
      opts.assert_valid_keys(options.keys)
      options.merge!(opts)

      grid_name = grid.name
      input_field_name = "#{grid_name}_saved_query_name"
      base_path_to_query_controller = create_serialized_query_url(:grid_name => grid_name)

      parameters = grid.get_state_as_parameter_value_pairs

      options[:extra_parameters].each do |k, v|
        parameters << [ CGI.unescape({:extra => {k => ''}}.to_query.sub(/=$/,'')) , v.to_s ]
      end
      parameters <<  ['authenticity_token', form_authenticity_token]
      notification_messages_id = "#{grid_name}_notification_messages"
      (%! <div class="wice_grid_query_panel"><h3>#{NlMessage['saved_query_panel_title']}</h3>! +
        saved_queries_list(grid_name, grid.saved_query, options[:extra_parameters]) +
        %!<div id="#{notification_messages_id}" ></div>! +
        if block_given?
          view, ids = yield
          view
        else
          ''
        end +
        '<div class="wg-saved-query-input-controls">'+
        text_field_tag(input_field_name,  '', :size => 20, :onkeydown=>'', :class => 'wice-grid-save-query-field') +
        button_tag(
          NlMessage['save_query_button_label'],
          :class => 'wice-grid-save-query-button',
          'data-grid-name'   => grid_name,
          'data-base-path-to-query-controller' => base_path_to_query_controller,
          'data-parameters'  => parameters.to_json,
          'data-ids'         => ids.to_json
        ) +
        '</div></div>'
        ).html_safe
    end

    def saved_queries_list(grid_name, saved_query = nil, extra_parameters = {})  #:nodoc:

      link_title            = NlMessage['saved_query_link_title']
      deletion_confirmation = NlMessage['saved_query_deletion_confirmation']
      deletion_link_title   = NlMessage['saved_query_deletion_link_title']

      query_store_model = ::Wice::get_query_store_model
      currently_loaded_query_id = saved_query ? saved_query.id : nil
      with = extra_parameters.nil? ? nil : "'"  + {:extra => extra_parameters}.to_query + "'"

      %!<ul id="#{grid_name}_query_list" class="query_list"> ! +
      query_store_model.list(grid_name, controller).collect do |sq|
        link_opts = {
          :class => 'wice-grid-query-load-link',
          :title => "#{link_title} #{sq.name}",
          'data-query-id' => sq.id,
          'data-grid-name' => grid_name
        }
        link_opts[:class] += ' current' if saved_query == sq
        "<li>"+
        link_to(
          image_tag(Defaults::DELETE_QUERY_ICON),
          delete_serialized_query_path(
            :grid_name => grid_name,
            :id => sq.id,
            :current => currently_loaded_query_id,
            :extra => extra_parameters
          ),
          :class => 'wice-grid-delete-query',
          'data-wg-confirm' => deletion_confirmation,
          'data-grid-name' => grid_name,
          :title => "#{deletion_link_title} #{sq.name}"
        )  + ' &nbsp; ' +
        link_to(h(sq.name), '#', link_opts) +
        if sq.respond_to? :description
          desc = sq.description
          desc.blank? ? '' : " <i>#{desc}</i>"
        else
          ''
        end +
        '</li>'
      end.join('') + '</ul>'
    end

  end
end