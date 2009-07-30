module Wice
  module JSCalendarHelpers  #:nodoc:

    include ActionView::Helpers::AssetTagHelper

    def select_date_datetime_common(options, date_string, html_opts)  #:nodoc:
      name = options[:prefix]

      dom_id = options[:id] || name.gsub(/([\[\(])|(\]\[)/, '_').gsub(/[\]\)]/, '').gsub(/\./, '_').gsub(/_+/, '_')

      trigger_id = dom_id + '_trigger'
      datepicker_placeholder_id = dom_id + '_date_placeholder'
      date_span_id = dom_id + '_date_view'

      date_picker = image_tag(Defaults::CALENDAR_ICON, :id => trigger_id, :style => 'cursor: pointer', :title => html_opts[:title]) +

      link_to_function(
        content_tag(:span, date_string, :id => date_span_id),
        %! $('#{date_span_id}').innerHTML = ''; $('#{dom_id}').value = ''; !,
        :class => 'date_label',
        :title => Defaults::DATE_STRING_TOOLTIP) + ' ' +

        hidden_field_tag(name, date_string, :class => 'text-input', :id => dom_id)
      return date_picker, datepicker_placeholder_id, trigger_id, dom_id, date_span_id
    end


    def date_calendar(initial_date, opts = {}, html_opts = {})  #:nodoc:
      options = {:prefix => 'date'}
      options.merge!(opts)
      date_format = Wice::Defaults::DATE_FORMAT

      date_string = initial_date.nil? ? '' : initial_date.strftime(date_format)
      date_picker, datepicker_placeholder_id, trigger_id, dom_id, date_span_id = select_date_datetime_common(options, date_string, html_opts)

      html = "<span id=\"#{datepicker_placeholder_id}\">#{date_picker}</span>"

      javascript =  %|    new Calendar({\n |
      javascript << %|      triggerElement : "#{trigger_id}",\n |
      javascript << %|      dateField : "#{dom_id}",\n |
      javascript << %|      extraOutputDateFields : $A([#{date_span_id}])\n |
      javascript << %|    });\n|

      [html, javascript]
    end

    def datetime_calendar(initial_date, opts = {}, html_opts = {})  #:nodoc:
      options = {:prefix => 'date'}
      options.merge!(opts)
      date_format = Wice::Defaults::DATETIME_FORMAT

      date_string = initial_date.nil? ? '' : initial_date.strftime(Wice::Defaults::DATETIME_FORMAT)
      date_picker, datepicker_placeholder_id, trigger_id, dom_id, date_span_id = select_date_datetime_common(options, date_string, html_opts)

      html = "<span id=\"#{datepicker_placeholder_id}\">#{date_picker}</span>"
      
      javascript = %|    new Calendar({\n|
      javascript << %|        triggerElement : "#{trigger_id}",\n|
      javascript << %|        dateField : "#{dom_id}",\n|
      javascript << %|        extraOutputDateFields : $A([#{date_span_id}]),\n |
      javascript << %|        withTime : true\n|
      javascript << %|    });\n|

      [html, javascript]
    end
  end
end