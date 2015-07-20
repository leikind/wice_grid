# encoding: utf-8
module Wice
  module Columns #:nodoc:
    module CommonJsDateDatetimeConditionsGeneratorMixin #:nodoc:

      def generate_conditions(table_alias, opts)   #:nodoc:

        datetime = @column_type == :datetime || @column_type == :timestamp

        conditions = [[]]
        if opts[:fr]
          conditions[0] << " #{@column_wrapper.alias_or_table_name(table_alias)}.#{@column_wrapper.name} >= ? "
          date = opts[:fr].to_date
          if datetime
            date = date.to_datetime
          end
          conditions << date
        end

        if opts[:to]
          op = '<='
          date = opts[:to].to_date
          if datetime
            date = (date + 1).to_datetime
            op = '<'
          end
          conditions[0] << " #{@column_wrapper.alias_or_table_name(table_alias)}.#{@column_wrapper.name} #{op} ? "
          conditions << date
        end

        return false if conditions.size == 1

        conditions[0] = conditions[0].join(' and ')
        conditions
      end

    end
  end
end
