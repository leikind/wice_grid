# encoding: utf-8
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
      def get_op_and_value(val)
        num = nil
        op  = nil

        # remove spaces
        val = val.gsub(' ', '')

        first_digit_or_dot_index = val =~ /[0-9.]/
        if first_digit_or_dot_index
          op = val[0...first_digit_or_dot_index]
          op = '=' if op == ''
          num = Float(val[first_digit_or_dot_index..-1]) rescue nil

          op = nil unless ['<', '>', '<=', '>=', '='].include?(op)
        end
        [op, num]
      end

      def  generate_conditions(table_alias, opts)   #:nodoc:
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
