module Wice
  module Columns #:nodoc:
    module CommonDateDatetimeMixin #:nodoc:

      def render_filter_internal(params) #:nodoc:
        prepare
        do_render(params)
      end

      def yield_declaration_of_column_filter #:nodoc:
        {
          templates: @queris_ids.collect { |tuple|  tuple[0] },
          ids:       @queris_ids.collect { |tuple|  tuple[1] }
        }
      end

    end
  end
end
