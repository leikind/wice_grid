# encoding: utf-8
module Wice #:nodoc:
  module JsCalendarHelpers #:nodoc:

    # A struct containing all data for rendering a calendar
    class CalendarData

      # :nodoc:
      attr_accessor :name,
                    :date_string,
                    :dom_id,
                    :datepicker_placeholder_id,
                    :date_span_id,
                    :close_calendar_event_name,
                    :title,
                    :fire_event,
                    :the_other_datepicker_id_to,
                    :the_other_datepicker_id_from
    end

    def date_calendar_jquery(calendar_data)  #:nodoc:
      hidden_field_tag_options = {
        :id                 => calendar_data.dom_id,
        'data-locale'       => I18n.locale,
        'data-date-format'  => Wice::ConfigurationProvider.value_for(:DATE_FORMAT_JQUERY),
        'data-button-text'  => calendar_data.title
      }

      if calendar_data.fire_event
        hidden_field_tag_options['data-close-calendar-event-name'] = calendar_data.close_calendar_event_name
      end

      if Rails.env.development?
        hidden_field_tag_options['class'] = 'check-for-datepicker'
      end

      if calendar_data.the_other_datepicker_id_to
        hidden_field_tag_options['data-the-other-datepicker-id-to'] = calendar_data.the_other_datepicker_id_to
      end

      if calendar_data.the_other_datepicker_id_from
        hidden_field_tag_options['data-the-other-datepicker-id-from'] = calendar_data.the_other_datepicker_id_from
      end

      if year_range = ConfigurationProvider.value_for(:DATEPICKER_YEAR_RANGE)
        hidden_field_tag_options['data-date-year-range'] = year_range
      end

      date_picker = hidden_field_tag(calendar_data.name, calendar_data.date_string, hidden_field_tag_options) + ' ' +

      link_to(
        calendar_data.date_string,
        '#',
        :id           => calendar_data.date_span_id,
        :class        => 'date-label',
        :title        => ::Wice::NlMessage['date_string_tooltip'],
        'data-dom-id' => calendar_data.dom_id
      )

      content_tag(
        :span,
        date_picker,
        id:    calendar_data.datepicker_placeholder_id,
        class: 'jq-datepicker-container'
      )
    end

    def prepare_data_for_calendar(options)  #:nodoc:
      date_format = Wice::ConfigurationProvider.value_for(:DATE_FORMAT)

      CalendarData.new.tap do |calendar_data|
        calendar_data.name                      = options[:name]
        calendar_data.date_string               = options[:initial_date].nil? ? '' : options[:initial_date].strftime(date_format)
        calendar_data.dom_id                    = options[:name].gsub(/([\[\(])|(\]\[)/, '_').gsub(/[\]\)]/, '').gsub(/\./, '_').gsub(/_+/, '_')
        calendar_data.datepicker_placeholder_id = calendar_data.dom_id + '_date_placeholder'
        calendar_data.date_span_id              = calendar_data.dom_id + '_date_view'
        calendar_data.close_calendar_event_name =  "wg:calendarChanged_#{options[:grid_name]}"
        calendar_data.title                     = options[:title]
        calendar_data.fire_event                = options[:fire_event]
      end
    end
  end
end
