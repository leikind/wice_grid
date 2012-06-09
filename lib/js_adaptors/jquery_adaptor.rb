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


      def fade_this(notification_messages_id)  #:nodoc:
        "$('##{notification_messages_id}').effect('fade')"
      end

    end

  end
end