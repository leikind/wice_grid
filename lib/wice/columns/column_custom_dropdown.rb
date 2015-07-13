module Wice

  module Columns #:nodoc:

    class ViewColumnCustomDropdown < ViewColumn #:nodoc:
      include ActionView::Helpers::FormOptionsHelper

      attr_accessor :filter_all_label
      attr_accessor :custom_filter

      def render_filter_internal(params) #:nodoc:
        @query, @query_without_equals_sign, @parameter_name, @dom_id = form_parameter_name_id_and_query('')
        @query_without_equals_sign += '%5B%5D='

        @custom_filter = @custom_filter.call if @custom_filter.kind_of? Proc

        if @custom_filter.kind_of? Array
          @custom_filter = [[@filter_all_label, nil]] + @custom_filter.map{|label, value|
            [label.to_s, value.to_s]
          }
        end

        select_options = {name: @parameter_name + '[]', id: @dom_id, class: 'custom-dropdown form-control'}

        if @turn_off_select_toggling
          select_toggle = ''
        else
          if self.allow_multiple_selection
            select_options[:multiple] = params.is_a?(Array) && params.size > 1

            expand_icon_style, collapse_icon_style = nil, 'display: none'
            expand_icon_style, collapse_icon_style = collapse_icon_style, expand_icon_style if select_options[:multiple]

            select_toggle = content_tag(:span, '',
              title: NlMessage['expand'],
              class: 'expand-multi-select-icon clickable',
              style: expand_icon_style
            ) +
            content_tag(:span, '',
              title: NlMessage['collapse'],
              class: 'collapse-multi-select-icon clickable',
              style: collapse_icon_style
            )
          else
            select_options[:multiple] = false
            select_toggle = ''
          end
        end

        if auto_reload
          select_options[:class] += ' auto-reload'
        end

        params_for_select = (params.is_a?(Hash) && params.empty?) ? [nil] : params

        '<div class="custom-dropdown-container">'.html_safe +
          content_tag(:select,
            options_for_select(@custom_filter, params_for_select),
            select_options) +  select_toggle.html_safe + '</div>'.html_safe
      end


      def yield_declaration_of_column_filter #:nodoc:
        {
          templates: [@query_without_equals_sign],
          ids:       [@dom_id]
        }
      end


      def has_auto_reloading_select? #:nodoc:
        auto_reload
      end
    end


    class ConditionsGeneratorColumnCustomDropdown < ConditionsGeneratorColumn #:nodoc:

      def generate_conditions(table_alias, opts)   #:nodoc:
        if opts.empty? || (opts.is_a?(Array) && opts.size == 1 && opts[0].blank?)
          return false
        end
        opts = (opts.kind_of?(Array) && opts.size == 1) ? opts[0] : opts

        if opts.kind_of?(Array)
          opts_with_special_values, normal_opts = opts.partition{|v| ::Wice::GridTools.special_value(v)}

          conditions_ar = if normal_opts.size > 0
            [" #{@column_wrapper.alias_or_table_name(table_alias)}.#{@column_wrapper.name} IN ( " + (['?'] * normal_opts.size).join(', ') + ' )'] + normal_opts
          else
            []
          end

          if opts_with_special_values.size > 0
            special_conditions = opts_with_special_values.collect{|v| " #{@column_wrapper.alias_or_table_name(table_alias)}.#{@column_wrapper.name} is " + v}.join(' or ')
            if conditions_ar.size > 0
              conditions_ar[0] = " (#{conditions_ar[0]} or #{special_conditions} ) "
            else
              conditions_ar = " ( #{special_conditions} ) "
            end
          end
          conditions_ar
        else
          if ::Wice::GridTools.special_value(opts)
            " #{@column_wrapper.alias_or_table_name(table_alias)}.#{@column_wrapper.name} is " + opts
          else
            [" #{@column_wrapper.alias_or_table_name(table_alias)}.#{@column_wrapper.name} = ?", opts]
          end
        end
      end

    end

  end

end