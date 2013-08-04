# encoding: UTF-8
module Wice

  module Columns #:nodoc:

    class ViewColumnBoolean < ViewColumnCustomDropdown #:nodoc:
      include ActionView::Helpers::FormOptionsHelper

      attr_accessor :boolean_filter_true_label, :boolean_filter_false_label

      def render_filter_internal(params) #:nodoc:
        @custom_filter = {
          @filter_all_label => nil,
          @boolean_filter_true_label  => 't',
          @boolean_filter_false_label => 'f'
        }

        @turn_off_select_toggling = true
        super(params)
      end
    end


    class ConditionsGeneratorColumnBoolean < ConditionsGeneratorColumn  #:nodoc:
      def  generate_conditions(table_alias, opts)   #:nodoc:
        unless (opts.kind_of?(Array) && opts.size == 1)
          Wice.log "invalid parameters for the grid boolean filter - must be an one item array: #{opts.inspect}"
          return false
        end
        opts = opts[0]
        if opts == 'f'
          [" (#{@column_wrapper.alias_or_table_name(table_alias)}.#{@column_wrapper.name} = ? or #{@column_wrapper.alias_or_table_name(table_alias)}.#{@column_wrapper.name} is null) ", false]
        elsif opts == 't'
          [" #{@column_wrapper.alias_or_table_name(table_alias)}.#{@column_wrapper.name} = ?", true]
        else
          nil
        end
      end
    end

  end

end