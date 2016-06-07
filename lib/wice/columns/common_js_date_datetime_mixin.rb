module Wice
  module Columns #:nodoc:
    module CommonJsDateDatetimeMixin #:nodoc:

      def prepare #:nodoc:
        query, _, @name1, @dom_id = form_parameter_name_id_and_query(fr: '')
        query2, _, @name2, @dom_id2 = form_parameter_name_id_and_query(to: '')

        @queris_ids = [[query, @dom_id], [query2, @dom_id2]]
      end

    end
  end
end
