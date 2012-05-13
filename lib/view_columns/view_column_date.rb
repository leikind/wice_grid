# encoding: UTF-8
module Wice

  class ViewColumnDate < ViewColumnDatetime #:nodoc:

    @@datetime_chunk_names = %w(year month day)

    def render_standard_filter_internal(params) #:nodoc:
      '<div class="date-filter">' +
      select_date(params[:fr], {:include_blank => true, :prefix => @name1, :id => @dom_id}) + '<br/>' +
      select_date(params[:to], {:include_blank => true, :prefix => @name2, :id => @dom_id2}) +
      '</div>'
    end

    def render_calendar_filter_internal(params) #:nodoc:

      html1 = date_calendar_jquery(
        params[:fr], NlMessage['date_selector_tooltip_from'], :prefix => @name1, :fire_event => auto_reload, :grid_name => self.grid.name)

      html2 = date_calendar_jquery(
        params[:to], NlMessage['date_selector_tooltip_to'],   :prefix => @name2, :fire_event => auto_reload, :grid_name => self.grid.name)

      [%!<div class="date-filter">#{html1}<br/>#{html2}</div>!, '']
    end

    def render_filter_internal(params) #:nodoc:

      if helper_style == :standard
        prepare_for_standard_filter
        render_standard_filter_internal(params)
      else
        prepare_for_calendar_filter
        render_calendar_filter_internal(params)
      end
    end
  end



end