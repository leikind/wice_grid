# encoding: UTF-8
module Wice

  class ViewColumnString < ViewColumn #:nodoc:

    attr_accessor :negation, :auto_reloading_input_with_negation_checkbox

    def render_filter_internal(params) #:nodoc:
      @contains_a_text_input = true
      css_class = auto_reload ? 'auto_reload' : nil

      if negation
        self.auto_reloading_input_with_negation_checkbox = true if auto_reload

        @query, _, parameter_name, @dom_id = form_parameter_name_id_and_query(:v => '')
        @query2, _, parameter_name2, @dom_id2 = form_parameter_name_id_and_query(:n => '')

        '<div class="text-filter-container">' +
          text_field_tag(parameter_name, params[:v], :size => 8, :id => @dom_id, :class => css_class) +
          if defined?(Wice::Defaults::NEGATION_CHECKBOX_LABEL) && ! Wice::ConfigurationProvider.value_for(:NEGATION_CHECKBOX_LABEL).blank?
            Wice::ConfigurationProvider.value_for(:NEGATION_CHECKBOX_LABEL)
          else
            ''
          end +
          check_box_tag(parameter_name2, '1', (params[:n] == '1'),
            :id => @dom_id2,
            :title => NlMessage['negation_checkbox_title'],
            :class => 'negation-checkbox') +
          '</div>'
      else
        @query, _, parameter_name, @dom_id = form_parameter_name_id_and_query('')
        text_field_tag(parameter_name, (params.blank? ? '' : params), :size => 8, :id => @dom_id, :class => css_class)
      end
    end


    def yield_declaration_of_column_filter #:nodoc:
      if negation
        {
          :templates => [@query, @query2],
          :ids       => [@dom_id, @dom_id2]
        }
      else
        {
          :templates => [@query],
          :ids       => [@dom_id]
        }
      end
    end


    def has_auto_reloading_input? #:nodoc:
      auto_reload
    end

    def auto_reloading_input_with_negation_checkbox? #:nodoc:
      self.auto_reloading_input_with_negation_checkbox
    end

  end


end