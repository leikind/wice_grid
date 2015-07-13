# It is here only until this pull request is pulled: https://github.com/amatsuda/kaminari/pull/267
module Kaminari #:nodoc:
  module Helpers #:nodoc:
    class Tag #:nodoc:
      def page_url_for(page) #:nodoc:
        current_page_params_as_query_string = @param_name.to_s + '=' + (page <= 1 ? nil : page).to_s
        current_page_params_as_hash = Rack::Utils.parse_nested_query(current_page_params_as_query_string)
        @template.url_for Wice::WgHash.rec_merge(@params, current_page_params_as_hash).symbolize_keys
      end
    end
  end
end
