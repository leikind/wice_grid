# encoding: utf-8
module Wice
  module Columns #:nodoc:
    class ViewColumnRailsDatetimeHelper < ViewColumn #:nodoc:

      include ActionView::Helpers::DateHelper
      include Wice::Columns::CommonDateDatetimeMixin
      include Wice::Columns::CommonStandardDateDatetimeMixin

      def chunk_names
        %w(year month day hour minute)
      end

      def do_render(params) #:nodoc:
        '<div class="date-filter">' +
          select_datetime(params[:fr], include_blank: true, prefix: @name1) + '<br/>' +
          select_datetime(params[:to], include_blank: true, prefix: @name2) +
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

    class ConditionsGeneratorColumnRailsDatetimeHelper < ConditionsGeneratorColumn  #:nodoc:

      include Wice::Columns::CommonJsDateDatetimeConditionsGeneratorMixin

    end
  end
end
