# encoding: UTF-8
module Wice

  module Columns #:nodoc:

    class ViewColumnDate < ViewColumnDatetime #:nodoc:

      @@datetime_chunk_names = %w(year month day)

      def render_standard_filter_internal(params) #:nodoc:
        '<div class="date-filter">' +
        select_date(params[:fr], {include_blank: true, prefix: @name1, id: @dom_id}) + '<br/>' +
        select_date(params[:to], {include_blank: true, prefix: @name2, id: @dom_id2}) +
        '</div>'
      end

    end

    ConditionsGeneratorColumnDate = ConditionsGeneratorColumnDatetime #:nodoc:

  end

end