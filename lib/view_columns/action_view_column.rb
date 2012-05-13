# encoding: UTF-8
module Wice

  class ActionViewColumn < ViewColumn #:nodoc:
    def initialize(grid_obj, html, param_name, select_all_buttons, object_property, view)  #:nodoc:
      @view = view
      @select_all_buttons   = select_all_buttons
      self.grid             = grid_obj
      self.html             = html
      self.html.add_or_append_class_value!('sel')
      grid_name             = self.grid.name
      @param_name           = param_name
      @cell_rendering_block = lambda do |object, params|
        selected = if params[grid_name] && params[grid_name][param_name] &&
                      params[grid_name][param_name].index(object.send(object_property).to_s)
          true
        else
          false
        end
        check_box_tag("#{grid_name}[#{param_name}][]", object.send(object_property), selected, :id => nil)
      end
    end

    def in_html  #:nodoc:
      true
    end

    def capable_of_hosting_filter_related_icons?  #:nodoc:
      false
    end

    def name  #:nodoc:
      return '' unless @select_all_buttons

      html = content_tag(:div, '',
        :class => 'clickable select-all',
        :title => NlMessage['select_all']) + ' ' +
      content_tag(:div, '',
        :class => 'clickable deselect-all',
        :title => NlMessage['deselect_all'])

      js = JsAdaptor.action_column_initialization(grid.name)

      [html, js]
    end

  end
end