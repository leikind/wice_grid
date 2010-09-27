# encoding: UTF-8
module Wice::JSCalendarHelpers  #:nodoc:
  module Jquery  #:nodoc:



    class << self
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::AssetTagHelper
      include ActionView::Helpers::JavaScriptHelper
      include ActionView::Helpers::FormTagHelper

      def calendar_constructor(popup_trigger_icon_id, dom_id, date_format, date_span_id, fireEvent, title, datepicker_placeholder_id)

        javascript = ''

        # unless @_wg_date_picker_language_initialized
        #   lang = Object.const_defined?(:I18n) ? I18n.locale : nil
        #   javascript << %|    $( "#datepicker" ).datepicker( $.datepicker.regional[ "fr" ] );\n| unless lang.blank?
        #   @_wg_date_picker_language_initialized = true
        # end


        # $( "##{dom_id}" ).datepicker( $.datepicker.regional[ "fr" ] );
        # $( "##{dom_id}" ).datepicker( "option", $.datepicker.regional[ $( this ).val() ] );


        javascript <<  %| $( "##{dom_id}" ).datepicker({\n|
        javascript <<  %|   firstDay: 1,\n|
        javascript <<  %|   showOn: "button",\n|
        javascript <<  %|   dateFormat: "#{date_format}",\n|
        javascript <<  %|   buttonImage: "#{::Wice::Defaults::CALENDAR_ICON}",\n|
        javascript <<  %|   buttonImageOnly: true,\n|
        javascript <<  %|   buttonText: "#{title}",\n|
        javascript <<  %|   onSelect: function(dateText, inst) {\n|
        javascript <<  %|     $("##{date_span_id}").html(dateText);\n|
        if fireEvent
          javascript <<  %|     $("##{dom_id}").trigger('wg:calendarChanged');\n|
        end
        javascript <<  %|   }\n|
        javascript <<  %| });\n|

        lang = Object.const_defined?(:I18n) ? I18n.locale : nil

        if lang
          javascript <<  %| $( "##{dom_id}" ).datepicker( "option", $.datepicker.regional['#{lang}'] );\n|
        end

        javascript += %| $('##{datepicker_placeholder_id} .ui-datepicker-trigger').addClass('clickable');\n|

        javascript
      end

      def select_date_datetime_common(initial_date, opts, html_opts, date_format, date_format_jquery)  #:nodoc:
        options = {:prefix => 'date'}
        options.merge!(opts)

        name = options[:prefix]

        date_string = initial_date.nil? ? '' : initial_date.strftime(date_format)

        dom_id = options[:id] || name.gsub(/([\[\(])|(\]\[)/, '_').gsub(/[\]\)]/, '').gsub(/\./, '_').gsub(/_+/, '_')

        popup_trigger_icon_id = dom_id + '_trigger'
        datepicker_placeholder_id = dom_id + '_date_placeholder'
        date_span_id = dom_id + '_date_view'

        function = %! $('##{date_span_id}').html(''); $('##{dom_id}')[0].value = ''; !
        date_picker =

        hidden_field_tag(name, date_string, :id => dom_id) + ' ' +

        link_to_function(
          content_tag(:span, date_string, :id => date_span_id),
          function,
          :class => 'date_label',
          :title => ::Wice::WiceGridNlMessageProvider.get_message(:DATE_STRING_TOOLTIP))


        html = "<span id=\"#{datepicker_placeholder_id}\">#{date_picker}</span>"

        javascript = calendar_constructor(popup_trigger_icon_id, dom_id,
          date_format_jquery, date_span_id, opts[:fire_event], html_opts[:title], datepicker_placeholder_id)



        [html, javascript]
      end


      def date_calendar(initial_date, opts = {}, html_opts = {})  #:nodoc:
        select_date_datetime_common(initial_date, opts, html_opts, Wice::Defaults::DATE_FORMAT, Wice::Defaults::DATE_FORMAT_JQUERY)
      end


    end
  end
end