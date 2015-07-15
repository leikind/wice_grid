# encoding: utf-8
module Wice
  module Columns #:nodoc:
    class ViewColumnDate < ViewColumnDatetime #:nodoc:
      def chunk_names
        %w(year month day)
      end

      def render_standard_filter_internal(params) #:nodoc:
        '<div class="date-filter">' +
          select_date(params[:fr], include_blank: true, prefix: @name1, id: @dom_id) + '<br/>' +
          select_date(params[:to], include_blank: true, prefix: @name2, id: @dom_id2) +
          '</div>'
      end
    end

    class ConditionsGeneratorColumnDate < ConditionsGeneratorColumn  #:nodoc:
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
