# encoding: utf-8
module Wice
  module Columns #:nodoc:
    class ViewColumnDatetime < ViewColumn #:nodoc:
      include ActionView::Helpers::DateHelper
      include Wice::BsCalendarHelpers
      include Wice::JsCalendarHelpers

      # name_and_id_from_options in Rails Date helper does not substitute '.' with '_'
      # like all other simpler form helpers do. Thus, overriding it here.
      def name_and_id_from_options(options, type)  #:nodoc:
        options[:name] = (options[:prefix] || DEFAULT_PREFIX) + (options[:discard_type] ? '' : "[#{type}]")
        options[:id] = options[:name].gsub(/([\[\(])|(\]\[)/, '_').gsub(/[\]\)]/, '').gsub(/\./, '_').gsub(/_+/, '_')
      end

      def chunk_names
        %w(year month day hour minute)
      end

      def prepare_for_standard_filter #:nodoc:
        x = lambda do|sym|
          chunk_names.map do|datetime_chunk_name|
            triple = form_parameter_name_id_and_query(sym => { datetime_chunk_name => '' })
            [triple[0], triple[3]]
          end
        end

        @queris_ids = x.call(:fr) + x.call(:to)

        _, _, @name1, _ = form_parameter_name_id_and_query(fr: '')
        _, _, @name2, _ = form_parameter_name_id_and_query(to: '')
      end

      def prepare_for_calendar_filter #:nodoc:
        query, _, @name1, @dom_id = form_parameter_name_id_and_query(fr: '')
        query2, _, @name2, @dom_id2 = form_parameter_name_id_and_query(to: '')

        @queris_ids = [[query, @dom_id], [query2, @dom_id2]]
      end

      def render_standard_filter_internal(params) #:nodoc:
        '<div class="date-filter">' +
          select_datetime(params[:fr], include_blank: true, prefix: @name1) + '<br/>' +
          select_datetime(params[:to], include_blank: true, prefix: @name2) +
          '</div>'
      end

      def render_html5_filter_internal(params) #:nodoc:
        css_class = 'form-control input-sm native-datepicker ' + (auto_reload ? 'auto-reload' : '')
        date_format = Wice::ConfigurationProvider.value_for(:DATE_FORMAT)
        '<div class="date-filter wg-html5-datepicker">' +
          date_field_tag(@name1, params[:fr].try(:strftime, date_format), class: css_class, id: @dom_id) + '<br/>' +
          date_field_tag(@name2, params[:to].try(:strftime, date_format), class: css_class, id: @dom_id2) +
          '</div>'
      end

      def render_bs_filter_internal(params) #:nodoc:
        calendar_data_from = prepare_data_for_bscalendar(
          initial_date: params[:fr],
          name:         @name1,
          fire_event:   auto_reload,
          grid_name:    self.grid.name
        )

        calendar_data_to = prepare_data_for_bscalendar(
          initial_date: params[:to],
          name:         @name2,
          fire_event:   auto_reload,
          grid_name:    self.grid.name
        )

        calendar_data_from.the_other_datepicker_id_to   = calendar_data_to.dom_id
        calendar_data_to.the_other_datepicker_id_from   = calendar_data_from.dom_id

        html1 = date_calendar_bs calendar_data_from

        html2 = date_calendar_bs calendar_data_to

        %(<div class="date-filter wg-bootstrap-datepicker">#{html1}#{html2}</div>)
      end

      def render_calendar_filter_internal(params) #:nodoc:
        calendar_data_from = prepare_data_for_calendar(
          initial_date: params[:fr],
          title:        NlMessage['date_selector_tooltip_from'],
          name:         @name1,
          fire_event:   auto_reload,
          grid_name:    self.grid.name
        )

        calendar_data_to = prepare_data_for_calendar(
          initial_date: params[:to],
          title:        NlMessage['date_selector_tooltip_to'],
          name:         @name2,
          fire_event:   auto_reload,
          grid_name:    self.grid.name
        )

        calendar_data_from.the_other_datepicker_id_to   = calendar_data_to.dom_id
        calendar_data_to.the_other_datepicker_id_from   = calendar_data_from.dom_id

        html1 = date_calendar_jquery calendar_data_from

        html2 = date_calendar_jquery calendar_data_to

        %(<div class="date-filter wg-jquery-datepicker">#{html1}<br/>#{html2}</div>)
      end

      def render_filter_internal(params) #:nodoc:
        if helper_style == :standard
          prepare_for_standard_filter
          render_standard_filter_internal(params)
        elsif helper_style == :html5
          prepare_for_calendar_filter
          render_html5_filter_internal(params)
        elsif helper_style == :bootstrap
          prepare_for_calendar_filter
          render_bs_filter_internal(params)
        else # :calendar
          prepare_for_calendar_filter
          render_calendar_filter_internal(params)
        end
      end

      def yield_declaration_of_column_filter #:nodoc:
        {
          templates: @queris_ids.collect { |tuple|  tuple[0] },
          ids:       @queris_ids.collect { |tuple|  tuple[1] }
        }
      end

      def has_auto_reloading_calendar? #:nodoc:
        auto_reload && [:bootstrap, :calendar].include?(helper_style)
      end
    end

    class ConditionsGeneratorColumnDatetime < ConditionsGeneratorColumn  #:nodoc:
      def generate_conditions(table_alias, opts)   #:nodoc:
        conditions = [[]]
        if opts[:fr]
          conditions[0] << " #{@column_wrapper.alias_or_table_name(table_alias)}.#{@column_wrapper.name} >= ? "
          conditions << opts[:fr]
        end

        if opts[:to]
          conditions[0] << " #{@column_wrapper.alias_or_table_name(table_alias)}.#{@column_wrapper.name} <= ? "
          conditions << (opts[:to])
        end

        return false if conditions.size == 1

        conditions[0] = conditions[0].join(' and ')
        conditions
      end
    end
  end
end
