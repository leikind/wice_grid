# encoding: utf-8
module Wice
  module Columns #:nodoc:
    class ViewColumnHtml5Datepicker < ViewColumn #:nodoc:

      include Wice::Columns::CommonDateDatetimeMixin
      include Wice::Columns::CommonJsDateDatetimeMixin

      def do_render(params) #:nodoc:
        css_class = 'form-control input-sm native-datepicker ' + (auto_reload ? 'auto-reload' : '')
        date_format = Wice::ConfigurationProvider.value_for(:DATE_FORMAT)
        '<div class="date-filter wg-html5-datepicker">' +
          date_field_tag(@name1, params[:fr].try(:strftime, date_format), class: css_class, id: @dom_id) + '<br/>' +
          date_field_tag(@name2, params[:to].try(:strftime, date_format), class: css_class, id: @dom_id2) +
          '</div>'
      end

      def has_auto_reloading_calendar? #:nodoc:
        # To be implemented
        false
      end

    end

    class ConditionsGeneratorColumnHtml5Datepicker < ConditionsGeneratorColumn  #:nodoc:
      def generate_conditions(table_alias, opts)   #:nodoc:
        conditions = [[]]
        if opts[:fr]
          conditions[0] << " #{@column_wrapper.alias_or_table_name(table_alias)}.#{@column_wrapper.name} >= ? "
          conditions << opts[:fr].to_date
        end

        if opts[:to]
          conditions[0] << " #{@column_wrapper.alias_or_table_name(table_alias)}.#{@column_wrapper.name} <= ? "
          conditions << (opts[:to].to_date + 1)
        end

        return false if conditions.size == 1

        conditions[0] = conditions[0].join(' and ')
        conditions
      end
    end
  end
end
