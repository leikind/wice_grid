# encoding: utf-8
module Wice
  module Columns #:nodoc:
    class ViewColumnRailsDateHelper < ViewColumn #:nodoc:

      include ActionView::Helpers::DateHelper
      include Wice::Columns::CommonDateDatetimeMixin
      include Wice::Columns::CommonStandardDateDatetimeMixin

      def chunk_names #:nodoc:
        %w(year month day)
      end

      def do_render(params) #:nodoc:
        '<div class="date-filter">' +
          select_date(params[:fr], include_blank: true, prefix: @name1, id: @dom_id) + '<br/>' +
          select_date(params[:to], include_blank: true, prefix: @name2, id: @dom_id2) +
          '</div>'
      end

      # name_and_id_from_options in Rails Date helper does not substitute '.' with '_'
      # like all other simpler form helpers do. Thus, overriding it here.
      def name_and_id_from_options(options, type)  #:nodoc:
        options[:name] = (options[:prefix] || DEFAULT_PREFIX) + (options[:discard_type] ? '' : "[#{type}]")
        options[:id] = options[:name].gsub(/([\[\(])|(\]\[)/, '_').gsub(/[\]\)]/, '').gsub(/\./, '_').gsub(/_+/, '_')
      end


      def has_auto_reloading_calendar? #:nodoc:
        false
      end

    end

    class ConditionsGeneratorColumnRailsDateHelper < ConditionsGeneratorColumn  #:nodoc:

      include Wice::Columns::CommonRailsDateDatetimeConditionsGeneratorMixin

    end
  end
end
