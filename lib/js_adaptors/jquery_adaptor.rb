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

      def reset_button_initialization(grid_name, reset_grid_javascript)  #:nodoc:
        %/ $('div##{grid_name}.wice_grid_container .reset').click(function(e){\n/+
        %/ #{reset_grid_javascript};\n/+
        %/ });\n/
      end

      def submit_button_initialization(grid_name, submit_grid_javascript)  #:nodoc:
        %/ $('div##{grid_name}.wice_grid_container .submit').click(function(e){\n/+
        %/  #{submit_grid_javascript};\n/+
        %/ });\n/
      end

      def show_hide_button_initialization(grid_name, filter_row_id)  #:nodoc:
        %/ $('##{grid_name}_show_icon').click(function(){\n/+
        %/   $('##{grid_name}_show_icon').hide();\n/+
        %/   $('##{grid_name}_hide_icon').show();\n/+
        %/   $('##{filter_row_id}').show();\n/+
        %/ })\n/+
        %/ $('##{grid_name}_hide_icon').click(function(){\n/+
        %/   $('##{grid_name}_show_icon').show();\n/+
        %/   $('##{grid_name}_hide_icon').hide();\n/+
        %/   $('##{filter_row_id}').hide();\n/+
        %/ });\n/
      end

      def enter_key_event_registration(grid_name)  #:nodoc:
        %! $('div##{grid_name}.wice_grid_container .wice_grid_filter_row input[type=text], .#{grid_name}_detached_filter input[type=text]').keydown(function(event){\n! +
        %!  if (event.keyCode == 13) {#{grid_name}.process()}\n! +
        %! });\n!
      end

      def csv_export_icon_initialization(grid_name)  #:nodoc:
        %! $('div##{grid_name}.wice_grid_container .export_to_csv_button').click(function(e){\n! +
        %!   #{grid_name}.export_to_csv()\n! +
        %! });\n!
      end

      def auto_reloading_selects_event_initialization(grid_name)  #:nodoc:
        %! $('div##{grid_name}.wice_grid_container select.auto_reload, .#{grid_name}_detached_filter select.auto_reload').change(function(e){\n! +
        %!   #{grid_name}.process()\n! +
        %! });\n!
      end

      def auto_reloading_inputs_event_initialization(grid_name)  #:nodoc:
        %! $('div##{grid_name}.wice_grid_container input.auto_reload, .#{grid_name}_detached_filter input.auto_reload').keyup(function(event, element){\n! +
        %!   #{grid_name}.set_process_timer(this.id);\n! +
        %! });\n!
      end

      def auto_reloading_inputs_with_negation_checkboxes_event_initialization(grid_name)  #:nodoc:
        %! $('div##{grid_name}.wice_grid_container input.negation_checkbox, .#{grid_name}_detached_filter input.negation_checkbox').click(function(event, element){\n! +
        %!   #{grid_name}.process(this.id);\n! +
        %! });\n!
      end


      def auto_reloading_calendar_event_initialization(grid_name)  #:nodoc:
        %! $(document).bind('wg:calendarChanged_#{grid_name}', function(event){\n! +
        %!   #{grid_name}.process()\n! +
        %! });\n!
      end

      def show_all_link_initialization(grid_name, confirmation, parameters_json)  #:nodoc:
        %/ $('div##{grid_name}.wice_grid_container .show_all_link').click(function(e){  \n/ +
        %/  #{confirmation} #{grid_name}.reload_page_for_given_grid_state(#{parameters_json})  \n/ +
        %/})\n/
      end

      def back_to_pagination_link_initialization(grid_name, parameters_json)  #:nodoc:
        %/ $('div##{grid_name}.wice_grid_container .show_all_link').click(function(e){\n/ +
        %/     #{grid_name}.reload_page_for_given_grid_state(#{parameters_json})\n/ +
        %/ })\n/
      end

      def call_to_save_query_and_key_event_initialization_for_saving_queries(
                                    id_and_name, grid_name, base_path_to_query_controller, parameters_json, ids_json)  #:nodoc:
        %/ function #{grid_name}_save_query(){\n/ +
        %`   if ( typeof(#{grid_name}) != "undefined")\n` +
        %!      #{grid_name}.save_query('#{id_and_name}', $('##{id_and_name}')[0].value, '#{base_path_to_query_controller}', #{parameters_json}, #{ids_json})\n! +
        %/}\n/ +
        %/ $('##{id_and_name}').keydown(function(event){\n/ +
        %/    if (event.keyCode == 13) #{grid_name}_save_query();\n/ +
        %/ })\n/
      end

      def js_framework_specific_calendar_assets(view)  #:nodoc:
        ''
      end

      def js_framework_specific_calendar_js_name  #:nodoc:
        nil
      end

      def js_framework_specific_calendar_css_name  #:nodoc:
        nil
      end

      def action_column_initialization(grid_name)  #:nodoc:
        %! $('div##{grid_name}.wice_grid_container .select_all').click(function(e){\n! +
        %!   $('div##{grid_name}.wice_grid_container .sel input').each(function(i, checkbox){\n! +
        %!     checkbox.checked = true;\n! +
        %!   })\n! +
        %! })\n! +
        %! $('div##{grid_name}.wice_grid_container .deselect_all').click(function(e){\n! +
        %!   $('div##{grid_name}.wice_grid_container .sel input').each(function(i, checkbox){\n! +
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
        %! $('div##{grid_name}.wice_grid_container .range-start, .#{grid_name}_detached_filter .range-start').keyup(function(e, a){\n! +
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