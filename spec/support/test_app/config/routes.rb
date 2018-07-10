# encoding: utf-8
Examples::TestApp.routes.draw do
  # just in order to have the helpers defined
  resources :tasks
  resources :projects

  resources :action_column do
    collection do
      post :process_issues
    end
  end

  resources :hiding_checkboxes_in_action_column do
    collection do
      post :process_issues
    end
  end

  resources :localization,
            :integration_with_application_view,
            :detached_filters,
            :csv_and_detached_filters,
            :detached_filters_two_grids,
            :csv_export,
            :all_records,
            :dates,
            :numeric_filters,
            :auto_reloads,
            :auto_reloads2,
            :auto_reloads3,
            :integration_with_forms,
            :erb_mode,
            :no_records,
            :adding_rows,
            :styling,
            :buttons,
            :null_values,
            :custom_filters4,
            :custom_filters3,
            :custom_filters2,
            :custom_filters1,
            :custom_ordering,
            :custom_ordering_with_proc,
            :custom_ordering_with_arel,
            :custom_ordering_with_ruby,
            :custom_ordering_on_calculated,
            :many_grids_on_page,
            :two_associations,
            :joining_tables,
            :basics6,
            :basics5,
            :basics4,
            :basics3,
            :upper_pagination_panel,
            :basics2,
            :basics1,
            :negation,
            :resultset_processings,
            :resultset_processings2,
            :custom_filter_params,
            :saved_queries,
            :blockless_column_definition,
            :disable_all_filters,
            :tasks,
            :when_filtered

  Wice.define_routes(self, 'queries')

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root to: 'basics1#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
