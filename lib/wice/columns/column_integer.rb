module Wice
  module Columns #:nodoc:
    class ViewColumnInteger < ViewColumn #:nodoc:
      def render_filter_internal(params) #:nodoc:
        @contains_a_text_input = true

        @query, _, parameter_name, @dom_id = form_parameter_name_id_and_query(eq: '')

        opts = { size: 3, id: @dom_id, class: 'range-start' }

        opts[:class] += ' form-control input-sm'

        if auto_reload
          opts[:class] += ' auto-reload'
        end

        text_field_tag(parameter_name,  params[:eq], opts)
      end

      def yield_declaration_of_column_filter #:nodoc:
        {
          templates: [@query],
          ids:       [@dom_id]
        }
      end

      def has_auto_reloading_input? #:nodoc:
        auto_reload
      end
    end

    class ConditionsGeneratorColumnInteger < ConditionsGeneratorColumn  #:nodoc:
      # Note: also used in ColumnRange, hence class method
      def self.get_value(val) #:nodoc:
        # Try to determine localized separator using I18n and replace it with default one
        separator = I18n.t!('number.format.separator') rescue nil
        val = val.sub(separator, '.') if val.respond_to?(:sub) && separator

        Integer(val) rescue nil
      end

      def get_op_and_value(val) #:nodoc:
        num = nil
        op  = nil

        # remove spaces
        val = val.gsub(' ', '')

        start_of_num = val =~ /[0-9.-]/ # first digit, dot or negative sign
        if start_of_num
          op = val[0...start_of_num]
          op = '=' if op == ''
          num = ConditionsGeneratorColumnInteger.get_value(val[start_of_num..-1])

          op = nil unless ['<', '>', '<=', '>=', '='].include?(op)
        end
        [op, num]
      end

      def generate_conditions(table_alias, opts)   #:nodoc:
        unless opts.is_a? Hash
          Wice.log 'invalid parameters for the grid integer filter - must be a hash'
          return false
        end
        conditions = [[]]
        if opts[:eq]
          op, num = get_op_and_value(opts[:eq])
          if op && num
            conditions[0] << " #{@column_wrapper.alias_or_table_name(table_alias)}.#{@column_wrapper.name} " + op + ' ? '
            conditions << num
          else
            opts.delete(:eq)
          end
        end

        if conditions.size == 1
          return false
        end

        conditions[0] = conditions[0].join(' and ')

        conditions
      end
    end
  end
end
