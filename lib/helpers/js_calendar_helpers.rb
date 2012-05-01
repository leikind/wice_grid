module Wice #:nodoc:
  module JsCalendarHelpers #:nodoc:

    def date_calendar_jquery(initial_date, title, opts = {})  #:nodoc:
      date_format = Wice::ConfigurationProvider.value_for(:DATE_FORMAT)

      name, date_string, dom_id, datepicker_placeholder_id, date_span_id, close_calendar_event_name  =
        prepare_data_for_calendar(opts, date_format, initial_date)

      hidden_field_tag_options = {
        :id => dom_id,
        'data-locale' => I18n.locale,
        'data-date-format' => Wice::ConfigurationProvider.value_for(:DATE_FORMAT_JQUERY),
        'data-button-image' => Wice::ConfigurationProvider.value_for(:CALENDAR_ICON),
        'data-button-text' => title,
      }

      if opts[:fire_event]
        hidden_field_tag_options['data-close-calendar-event-name'] = close_calendar_event_name
      end

      if Rails.env == 'development'
        hidden_field_tag_options['class'] = 'check-for-datepicker'
      end

      date_picker = hidden_field_tag(name, date_string, hidden_field_tag_options) + ' ' +

        link_to(date_string,
          '#',
          :id => date_span_id,
          :class => 'date-label',
          :title => ::Wice::NlMessage['date_string_tooltip'],
          'data-dom-id' => dom_id
        )

      "<span id=\"#{datepicker_placeholder_id}\">#{date_picker}</span>"
    end

    protected

    def prepare_data_for_calendar(opts, date_format, initial_date)  #:nodoc:
      options = {:prefix => 'date'}
      options.merge!(opts)
      name = options[:prefix]
      date_string = initial_date.nil? ? '' : initial_date.strftime(date_format)
      dom_id = name.gsub(/([\[\(])|(\]\[)/, '_').gsub(/[\]\)]/, '').gsub(/\./, '_').gsub(/_+/, '_')
      datepicker_placeholder_id = dom_id + '_date_placeholder'
      date_span_id = dom_id + '_date_view'
      close_calendar_event_name =  "wg:calendarChanged_#{options[:grid_name]}"
      return name, date_string, dom_id, datepicker_placeholder_id, date_span_id, close_calendar_event_name
    end

  end
end
