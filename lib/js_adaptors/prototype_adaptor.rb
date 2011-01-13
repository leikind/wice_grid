# encoding: UTF-8
module Wice::JsAdaptor  #:nodoc:

  module Prototype    #:nodoc:

    def self.included(base)   #:nodoc:
      base.extend(ClassMethods)
    end

    module ClassMethods   #:nodoc:
      def init  #:nodoc:
      end

      def dom_loaded  #:nodoc:
        %/ document.observe("dom:loaded", function() {\n/
      end

      def reset_button_initialization(grid_name, reset_grid_javascript)  #:nodoc:
        %/ $$('div##{grid_name}.wice_grid_container .reset').each(function(e){\n/+
        %/   e.observe('click', function(){\n/+
        %/     #{reset_grid_javascript};\n/+
        %/   })\n/+
        %/ });\n/
      end

      def submit_button_initialization(grid_name, submit_grid_javascript)  #:nodoc:
        %/ $$('div##{grid_name}.wice_grid_container .submit').each(function(e){\n/+
        %/   e.observe('click', function(){\n/+
        %/     #{submit_grid_javascript};\n/+
        %/   })\n/+
        %/ });\n/
      end

      def show_hide_button_initialization(grid_name, filter_row_id)  #:nodoc:
        %/ $('#{grid_name}_show_icon').observe('click', function(){\n/+
        %/   Element.toggle('#{grid_name}_show_icon');\n/+
        %/   Element.toggle('#{grid_name}_hide_icon');\n/+
        %/   $('#{filter_row_id}').show();\n/+
        %/ })\n/+
        %/ $('#{grid_name}_hide_icon').observe('click', function(){\n/+
        %/   Element.toggle('#{grid_name}_show_icon');\n/+
        %/   Element.toggle('#{grid_name}_hide_icon');\n/+
        %/   $('#{filter_row_id}').hide();\n/+
        %/ });\n/
      end

      def enter_key_event_registration(grid_name)  #:nodoc:
        %! $$('div##{grid_name}.wice_grid_container .wice_grid_filter_row input[type=text]').each(function(e){\n! +
        %!   e.observe('keydown', function(event){\n! +
        %!     if (event.keyCode == 13) {#{grid_name}.process()}\n! +
        %!   })\n! +
        %! });\n!
      end

      def csv_export_icon_initialization(grid_name)  #:nodoc:
        %! $$('div##{grid_name}.wice_grid_container .export_to_csv_button').each(function(e){\n! +
        %!   e.observe('click', function(event){\n! +
        %!     #{grid_name}.export_to_csv()\n! +
        %!   })\n! +
        %! });\n!
      end

      def auto_reloading_selects_event_initialization(grid_name)  #:nodoc:
        %! $$('div##{grid_name}.wice_grid_container select.auto_reload', '.#{grid_name}_detached_filter select.auto_reload').each(function(e){\n! +
        %!   e.observe('change', function(event){\n! +
        %!     #{grid_name}.process()\n! +
        %!   })\n! +
        %! });\n!
      end

      def auto_reloading_inputs_event_initialization(grid_name)  #:nodoc:
        %! $$('div##{grid_name}.wice_grid_container input.auto_reload', '.#{grid_name}_detached_filter input.auto_reload').each(function(e){\n! +
        %!   e.observe('keyup', function(event){\n! +
        %!     #{grid_name}.process(event.element().id)\n! +
        %!   })\n! +
        %! });\n!
      end

      def auto_reloading_inputs_with_negation_checkboxes_event_initialization(grid_name)  #:nodoc:
        %! $$('div##{grid_name}.wice_grid_container input.negation_checkbox', '.#{grid_name}_detached_filter input.negation_checkbox').each(function(e){\n! +
        %!   e.observe('click', function(event){\n! +
        %!     #{grid_name}.process(event.element().id)\n! +
        %!   })\n! +
        %! });\n!
      end


      def auto_reloading_calendar_event_initialization(grid_name)  #:nodoc:
        %! document.observe('wg:calendarChanged_#{grid_name}', function(event){\n! +
        %!   #{grid_name}.process()\n! +
        %! });\n!
      end


      def show_all_link_initialization(grid_name, confirmation, parameters_json)  #:nodoc:
        %/ $$('div##{grid_name}.wice_grid_container .show_all_link').each(function(e){\n/ +
        %/   e.observe('click', function(){\n/ +
        %/     #{confirmation} #{grid_name}.reload_page_for_given_grid_state(#{parameters_json})\n/ +
        %/   })\n/ +
        %/ })\n/
      end


      def back_to_pagination_link_initialization(grid_name, parameters_json)  #:nodoc:
        %/ $$('div##{grid_name}.wice_grid_container .show_all_link').each(function(e){\n/ +
        %/   e.observe('click', function(){\n/ +
        %/     #{grid_name}.reload_page_for_given_grid_state(#{parameters_json})\n/ +
        %/   })\n/ +
        %/ })\n/
      end

      def call_to_save_query_and_key_event_initialization_for_saving_queries(
                                        id_and_name, grid_name, base_path_to_query_controller, parameters_json, ids_json)  #:nodoc:
        %/ function #{grid_name}_save_query(){\n/ +
        %`   if ( typeof(#{grid_name}) != "undefined")\n` +
        %/     #{grid_name}.save_query($F('#{id_and_name}'), '#{base_path_to_query_controller}', #{parameters_json}, #{ids_json})\n/ +
        %/   }\n/ +
        %/ $('#{id_and_name}').observe('keydown', function(event){\n/ +
        %/   if (event.keyCode == 13) #{grid_name}_save_query();\n/ +
        %/ })\n/
      end


      def js_framework_specific_calendar_assets(view)  #:nodoc:
        view.stylesheet_link_tag("calendarview.css") + view.javascript_include_tag("calendarview.js")
      end

      def js_framework_specific_calendar_js_name  #:nodoc:
        'calendarview.js'
      end

      def js_framework_specific_calendar_css_name  #:nodoc:
        'calendarview.css'
      end


      def action_column_initialization(grid_name)  #:nodoc:
        %! $$('div##{grid_name}.wice_grid_container .select_all').each(function(e){\n! +
        %!   e.observe('click', function(){\n! +
        %!     $$('div##{grid_name}.wice_grid_container .sel input').each(function(checkbox){\n! +
        %!       checkbox.checked = true;\n! +
        %!     })\n! +
        %!   })\n! +
        %! })\n! +
        %! $$('div##{grid_name}.wice_grid_container .deselect_all').each(function(e){\n! +
        %!   e.observe('click', function(){\n! +
        %!     $$('div##{grid_name}.wice_grid_container .sel input').each(function(checkbox){\n! +
        %!       checkbox.checked = false;\n! +
        %!     })\n! +
        %!   })\n! +
        %! })\n!
      end

      def fade_this(notification_messages_id)  #:nodoc:
        "new Effect.Fade(this)"
      end

      def focus_element(element_to_focus)  #:nodoc:
        %! var elToFocus = $('#{element_to_focus}');\n! +
        %! elToFocus.focus();\n! +
        %! elToFocus.value = elToFocus.value;\n! # this will just place the cursor at the end of the text input
      end

    end

  end

end