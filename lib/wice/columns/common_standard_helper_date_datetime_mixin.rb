# encoding: utf-8
module Wice
  module Columns #:nodoc:
    module CommonStandardDateDatetimeMixin #:nodoc:

      def prepare #:nodoc:
        x = lambda do|sym|
          chunk_names.map do|datetime_chunk_name|
            triple = form_parameter_name_id_and_query(sym => { datetime_chunk_name => '' })
            [triple[0], triple[3]]
          end
        end

        @queris_ids = x.call(:fr) + x.call(:to)

        _, _, @name1, _ = form_parameter_name_id_and_query(fr: '')
        _, _, @name2, _ = form_parameter_name_id_and_query(to: '')
      end

    end
  end
end
