module Wice
  class <<self
    # Used in routes.rb to define routes to the query processing controller.
    # Parameters:
    # * map - the mapper object used in routes.rb to defined routes (instance of <tt>ActionController::Routing::RouteSet::Mapper</tt>)
    # * controller - name of the query processing controller, i.e.  <tt>'queries'</tt> if the controller is +QueriesController+ .
    # Read section "Saving Queries How-To" in README for more details.
    def define_routes(map, controller)
      controller = controller.to_s
      map.create_serialized_query '/wice_grid_serialized_queries/:grid_name',
        :controller => controller,
        :action => 'create',
        :conditions => {:method => :post}
      map.delete_serialized_query '/wice_grid_serialized_query/:grid_name/:id',
        :controller => controller,
        :action => 'delete',
        :conditions => {:method => :post}
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
          @notification_messages = WiceGridNlMessageProvider.get_message(:QUERY_DELETED_MESSAGE)
        else
          @error_messages = sq.errors.full_raw_messages.join(' ')
        end
      end
      render :file => "#{RAILS_ROOT}/vendor/plugins/wice_grid/lib/views/delete.rjs"
    end

    def create  #:nodoc:
      init
      query_params = if params[@grid_name]
        params[@grid_name]
      else
        {}
      end
      query_params.delete(:page)

      @saved_query = @query_store_model.new(:grid_name => @grid_name, :name => params[:query_name], :query => query_params)

      @saved_query.attributes = params[:extra] unless params[:extra].blank?

      if @saved_query.save
        @grid_title_id = "#{@grid_name}_title"
        @notification_messages = WiceGridNlMessageProvider.get_message(:QUERY_SAVED_MESSAGE)
      else
        @error_messages = @saved_query.errors.map{ |_, msg| msg }.join(' ')
      end

      render :file => "#{RAILS_ROOT}/vendor/plugins/wice_grid/lib/views/create.rjs"
    end

    def extra
      params[:extra]
    end

    protected

    def init  #:nodoc:
      @query_store_model = ::Wice::get_query_store_model

      @grid_name = params[:grid_name]
      @notification_messages_dom_id = "#{@grid_name}_notification_messages"
      @query_list_dom_id = "#{@grid_name}_query_list"

    end
  end
end