# encoding: UTF-8
module Wice

  class ViewColumnInteger < ViewColumn #:nodoc:

    def render_filter_internal(params) #:nodoc:
      @contains_a_text_input = true

      @query, _, parameter_name, @dom_id = form_parameter_name_id_and_query(:fr => '')
      @query2, _, parameter_name2, @dom_id2 = form_parameter_name_id_and_query(:to => '')

      opts1 = {:size => 3, :id => @dom_id,  :class => 'range-start'}
      opts2 = {:size => 3, :id => @dom_id2, :class => 'range-end'}

      if auto_reload
        opts1[:class] += ' auto-reload'
        opts2[:class] += ' auto-reload'
      end

      text_field_tag(parameter_name,  params[:fr], opts1) + text_field_tag(parameter_name2, params[:to], opts2)
    end

    def yield_declaration_of_column_filter #:nodoc:
      {
        :templates => [@query, @query2],
        :ids       => [@dom_id, @dom_id2]
      }
    end


    def has_auto_reloading_input? #:nodoc:
      auto_reload
    end

  end


end