module Wice
  module JsCalendarHelpers

    include ActionView::Helpers::AssetTagHelper
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::JavaScriptHelper
    include ActionView::Helpers::FormTagHelper

    def calendar_constructor_jquery(dom_id, date_format, date_span_id, fireEvent, title, datepicker_placeholder_id)

      javascript  =  %| $( "##{dom_id}" ).datepicker({\n|
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
        javascript <<  %| var regionalOptions = $.datepicker.regional['#{lang}']  ;\n|
        javascript <<  %| delete regionalOptions.dateFormat ;\n|
        javascript <<  %| delete regionalOptions.firstDate ;\n|
        javascript <<  %| $( "##{dom_id}" ).datepicker( "option", $.datepicker.regional['#{lang}'] );\n|
      end

      javascript += %| $('##{datepicker_placeholder_id} .ui-datepicker-trigger').addClass('clickable');\n|

      javascript
    end


    def date_calendar_jquery(initial_date, opts = {}, html_opts = {})  #:nodoc:
      options = {:prefix => 'date'}
      options.merge!(opts)

      name = options[:prefix]

      date_string = initial_date.nil? ? '' : initial_date.strftime(Wice::Defaults::DATE_FORMAT)

      dom_id = options[:id] || name.gsub(/([\[\(])|(\]\[)/, '_').gsub(/[\]\)]/, '').gsub(/\./, '_').gsub(/_+/, '_')

      datepicker_placeholder_id = dom_id + '_date_placeholder'
      date_span_id = dom_id + '_date_view'

      remove_date_function = %! $('##{date_span_id}').html(''); $('##{dom_id}')[0].value = ''; !

      date_picker =

        text_field_tag(name, date_string, :id => dom_id) + ' ' +

        link_to_function(
          content_tag(:span, date_string, :id => date_span_id),
          remove_date_function,
          :class => 'date_label',
          :title => ::Wice::WiceGridNlMessageProvider.get_message(:DATE_STRING_TOOLTIP))

      html = "<span id=\"#{datepicker_placeholder_id}\">#{date_picker}</span>"

      javascript = calendar_constructor_jquery(dom_id, Wice::Defaults::DATE_FORMAT_JQUERY,
        date_span_id, opts[:fire_event], html_opts[:title], datepicker_placeholder_id)

      [html, javascript]
    end

    # Prototype

    def calendar_constructor_prototype(popup_trigger_icon_id, dom_id, date_format, date_span_id, with_time, fireEvent)

      javascript = ''

      unless @_wg_date_picker_language_initialized
        lang = Object.const_defined?(:I18n) ? I18n.locale : nil
        javascript << %|    Calendar.language = '#{lang}';\n| unless lang.blank?
        @_wg_date_picker_language_initialized = true
      end

      javascript <<  %|    new Calendar({\n |
      javascript << %|      popupTriggerElement : "#{popup_trigger_icon_id}",\n |
      javascript << %|      initialDate : $('#{dom_id}').value,\n |
      if fireEvent
        javascript << %|      onHideCallback : function(){Event.fire($(#{dom_id}), 'wg:calendarChanged')},\n |
      end
      javascript << %|      dateFormat : "#{date_format}",\n|
      unless Wice::Defaults::POPUP_PLACEMENT_STRATEGY == :trigger
        javascript << %|      popupPositioningStrategy : "#{Wice::Defaults::POPUP_PLACEMENT_STRATEGY}",\n|
      end
      if with_time
        javascript << %|        withTime : true,\n|
      end
      javascript << %|      outputFields : $A(['#{date_span_id}', '#{dom_id}'])\n |
      javascript << %|    });\n|

      javascript
    end

    def select_date_datetime_common_prototype(initial_date, opts, html_opts, with_time, date_format)  #:nodoc:
      options = {:prefix => 'date'}
      options.merge!(opts)

      name = options[:prefix]

      date_string = initial_date.nil? ? '' : initial_date.strftime(date_format)

      dom_id = options[:id] || name.gsub(/([\[\(])|(\]\[)/, '_').gsub(/[\]\)]/, '').gsub(/\./, '_').gsub(/_+/, '_')

      popup_trigger_icon_id = dom_id + '_trigger'
      datepicker_placeholder_id = dom_id + '_date_placeholder'
      date_span_id = dom_id + '_date_view'

      function = %! $('#{date_span_id}').innerHTML = ''; $('#{dom_id}').value = ''; !
      if opts[:fire_event]
        function += "Event.fire($(#{dom_id}), 'wg:calendarChanged')"
      end

      date_picker = image_tag(Defaults::CALENDAR_ICON,
        :id => popup_trigger_icon_id,
        :class => 'clickable',
        :title => html_opts[:title]) +

      link_to_function(
        content_tag(:span, date_string, :id => date_span_id),
        function,
        :class => 'date_label',
        :title => WiceGridNlMessageProvider.get_message(:DATE_STRING_TOOLTIP)) + ' ' +

        hidden_field_tag(name, date_string, :class => 'text-input', :id => dom_id)

      html = "<span id=\"#{datepicker_placeholder_id}\">#{date_picker}</span>"

      javascript = calendar_constructor_prototype(popup_trigger_icon_id, dom_id, date_format, date_span_id, with_time, opts[:fire_event])

      [html, javascript]
    end

    def date_calendar_prototype(initial_date, opts = {}, html_opts = {})  #:nodoc:
      select_date_datetime_common_prototype(initial_date, opts, html_opts, false, Wice::Defaults::DATE_FORMAT)
    end

    def datetime_calendar_prototype(initial_date, opts = {}, html_opts = {})  #:nodoc:
      select_date_datetime_common_prototype(initial_date, opts, html_opts, true, Wice::Defaults::DATETIME_FORMAT)
    end


  end
end
