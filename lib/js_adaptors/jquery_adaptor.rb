# encoding: UTF-8
module Wice::JsAdaptor   #:nodoc:

  module Jquery   #:nodoc:

    def self.included(base)   #:nodoc:
      base.extend(ClassMethods)
    end

    module ClassMethods   #:nodoc:

      def init  #:nodoc:
      end

      def dom_loaded  #:nodoc:
        %/$(document).ready(function(){\n/
      end

      def csv_export_icon_initialization(grid_name)  #:nodoc:
        %! $('div##{grid_name}.wice-grid-container .export_to_csv_button').click(function(e){\n! +
        %!   #{grid_name}.exportToCsv()\n! +
        %! });\n!
      end

      def auto_reloading_selects_event_initialization(grid_name)  #:nodoc:
        %! $('div##{grid_name}.wice-grid-container select.auto_reload, .#{grid_name}_detached_filter select.auto_reload').change(function(e){\n! +
        %!   #{grid_name}.process()\n! +
        %! });\n!
      end

      def auto_reloading_inputs_event_initialization(grid_name)  #:nodoc:
        %! $('div##{grid_name}.wice-grid-container input.auto_reload, .#{grid_name}_detached_filter input.auto_reload').keyup(function(event, element){\n! +
        %!   #{grid_name}.setProcessTimer(this.id);\n! +
        %! });\n!
      end

      def auto_reloading_inputs_with_negation_checkboxes_event_initialization(grid_name)  #:nodoc:
        %! $('div##{grid_name}.wice-grid-container input.negation-checkbox, .#{grid_name}_detached_filter input.negation-checkbox').click(function(event, element){\n! +
        %!   #{grid_name}.process(this.id);\n! +
        %! });\n!
      end


      def auto_reloading_calendar_event_initialization(grid_name)  #:nodoc:
        %! $(document).bind('wg:calendarChanged_#{grid_name}', function(event){\n! +
        %!   #{grid_name}.process()\n! +
        %! });\n!
      end


      def call_to_save_query_and_key_event_initialization_for_saving_queries(
                                    id_and_name, grid_name, base_path_to_query_controller, parameters_json, ids_json)  #:nodoc:
        %/ function #{grid_name}_save_query(){\n/ +
        %`   if ( typeof(#{grid_name}) != "undefined")\n` +
        %!      #{grid_name}.saveQuery('#{id_and_name}', $('##{id_and_name}')[0].value, '#{base_path_to_query_controller}', #{parameters_json}, #{ids_json})\n! +
        %/}\n/ +
        %/ $('##{id_and_name}').keydown(function(event){\n/ +
        %/    if (event.keyCode == 13) #{grid_name}_save_query();\n/ +
        %/ })\n/
      end



      def action_column_initialization(grid_name)  #:nodoc:
        %! $('div##{grid_name}.wice-grid-container .select-all').click(function(e){\n! +
        %!   $('div##{grid_name}.wice-grid-container .sel input').each(function(i, checkbox){\n! +
        %!     checkbox.checked = true;\n! +
        %!   })\n! +
        %! })\n! +
        %! $('div##{grid_name}.wice-grid-container .deselect-all').click(function(e){\n! +
        %!   $('div##{grid_name}.wice-grid-container .sel input').each(function(i, checkbox){\n! +
        %!     checkbox.checked = false;\n! +
        %!   })\n! +
        %! })\n!
      end

      def fade_this(notification_messages_id)  #:nodoc:
        "$('##{notification_messages_id}').effect('fade')"
      end

      def focus_element(element_to_focus)  #:nodoc:
        %! var elements = $('##{element_to_focus}');\n! +
        %! if (elements[0]){\n! +
        %!   var elToFocus = elements[0];\n! +
        %!   elToFocus.value = elToFocus.value;\n! + # this will just place the cursor at the end of the text input
        %!   elToFocus.focus();\n! +
        %! }\n!
      end


      def update_ranges(grid_name)
        %! $('div##{grid_name}.wice-grid-container .range-start, .#{grid_name}_detached_filter .range-start').keyup(function(e, a){\n! +
        %!   var endRange = $(e.target).next();\n! +
        %!   if (e.target.value){\n! +
        %!     endRange.val(#{Wice::ConfigurationProvider.value_for(:SECOND_RANGE_VALUE_FOLLOWING_THE_FIRST)} + parseInt(e.target.value));\n! +
        %!     }else{\n! +
        %!       endRange.val('');\n! +
        %!     }\n! +
        %! });\n!
      end

    end

  end
end