# encoding: UTF-8
module Wice
  class <<self
    # Used in routes.rb to define routes to the query processing controller.
    # Parameters:
    # * map - the mapper object used in routes.rb to defined routes (instance of <tt>ActionController::Routing::RouteSet::Mapper</tt>)
    # * controller - name of the query processing controller, i.e.  <tt>'queries'</tt> if the controller is +QueriesController+ .
    # Read section "Saving Queries How-To" in README for more details.
    def define_routes(map, controller)
      controller = controller.to_s
      # if Rails.version[0..1] == '3.'

      #   map.match '/wice_grid_serialized_queries/:grid_name',
      #     :to => "#{controller}#create",
      #     :as => 'create_serialized_query'

      #   map.match '/wice_grid_serialized_queries/:grid_name/:id',
      #     :to => "#{controller}#delete",
      #     :as => 'delete_serialized_query'

      # else

        map.post '/wice_grid_serialized_queries/:grid_name',
          :to => "#{controller}#create",
          :as => 'create_serialized_query'

        map.post '/wice_grid_serialized_queries/:grid_name/:id',
          :to => "#{controller}#delete",
          :as => 'delete_serialized_query'

      # end
    end
  end

  module SerializedQueriesControllerMixin   #:nodoc:

    def delete  #:nodoc:
      init
      if sq = @query_store_model.find_by_id_and_grid_name(params[:id], @grid_name)
        if sq.destroy
          if params[:current]
            @current = @query_store_model.find_by_id_and_grid_name(params[:current], @grid_name)
          end
          @notification_messages = NlMessage['query_deleted_message']
        else
          @error_messages = sq.errors.full_raw_messages.join(' ')
        end
      end

      render_asyns_result
    end

    def create  #:nodoc:
      init
      query_params = if params[@grid_name]
        params[@grid_name]
      else
        {}
      end
      query_params.delete(:page)

      @saved_query = @query_store_model.new

      @saved_query.grid_name = @grid_name
      @saved_query.name      = params[:query_name]
      @saved_query.query     = query_params

      @saved_query.attributes = params[:extra] unless params[:extra].blank?

      if @saved_query.save
        @grid_title_id = "#{@grid_name}_title"
        @notification_messages = NlMessage['query_saved_message']
      else
        @error_messages = @saved_query.errors.map{ |_, msg| msg }.join(' ')
      end

      render_asyns_result
    end

    def extra
      params[:extra]
    end

    protected

    def render_asyns_result
      render :json => {
        'error_messages' => @error_messages,
        'notification_messages' => @notification_messages,
        'query_list' => render_to_string(:inline => '<%=saved_queries_list(@grid_name, @saved_query, controller.extra, @confirm).html_safe%>')
      }
    end

    def init  #:nodoc:
      @query_store_model = ::Wice::get_query_store_model
      @confirm = params[:confirm] == '1' || params[:confirm] == 'true'
      @grid_name = params[:grid_name]
    end
  end
end