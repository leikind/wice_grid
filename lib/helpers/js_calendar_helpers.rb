module Wice
  module JSCalendarHelpers  #:nodoc:

    include ActionView::Helpers::AssetTagHelper

    def calendar_constructor(popup_trigger_icon_id, dom_id, date_format, date_span_id, with_time)

      javascript = ''

      unless @_wg_date_picker_language_initialized
        lang = Object.const_defined?(:I18n) ? I18n.locale : nil
        javascript << %|    Calendar.language = '#{lang}';\n| unless lang.blank?
        @_wg_date_picker_language_initialized = true
      end

      javascript <<  %|    new Calendar({\n |
      javascript << %|      popupTriggerElement : "#{popup_trigger_icon_id}",\n |
      javascript << %|      initialDate : $('#{dom_id}').value,\n |
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

    def select_date_datetime_common(initial_date, opts, html_opts, with_time, date_format)  #:nodoc:
      options = {:prefix => 'date'}
      options.merge!(opts)

      name = options[:prefix]

      date_string = initial_date.nil? ? '' : initial_date.strftime(date_format)

      dom_id = options[:id] || name.gsub(/([\[\(])|(\]\[)/, '_').gsub(/[\]\)]/, '').gsub(/\./, '_').gsub(/_+/, '_')

      popup_trigger_icon_id = dom_id + '_trigger'
      datepicker_placeholder_id = dom_id + '_date_placeholder'
      date_span_id = dom_id + '_date_view'

      date_picker = image_tag(Defaults::CALENDAR_ICON, :id => popup_trigger_icon_id, :style => 'cursor: pointer', :title => html_opts[:title]) +

      link_to_function(
        content_tag(:span, date_string, :id => date_span_id),
        %! $('#{date_span_id}').innerHTML = ''; $('#{dom_id}').value = ''; !,
        :class => 'date_label',
        :title => WiceGridNlMessageProvider.get_message(:DATE_STRING_TOOLTIP)) + ' ' +

        hidden_field_tag(name, date_string, :class => 'text-input', :id => dom_id)

      html = "<span id=\"#{datepicker_placeholder_id}\">#{date_picker}</span>"

      javascript = calendar_constructor(popup_trigger_icon_id, dom_id, date_format, date_span_id, with_time)

      [html, javascript]
    end


    def date_calendar(initial_date, opts = {}, html_opts = {})  #:nodoc:
      select_date_datetime_common(initial_date, opts, html_opts, false, Wice::Defaults::DATE_FORMAT)
    end

    def datetime_calendar(initial_date, opts = {}, html_opts = {})  #:nodoc:
      select_date_datetime_common(initial_date, opts, html_opts, true, Wice::Defaults::DATETIME_FORMAT)
    end
  end
end