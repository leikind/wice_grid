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

  resources(
    :adding_rows,
    :all_records,
    :auto_reloads,
    :auto_reloads2,
    :auto_reloads3,
    :basics1,
    :basics2,
    :basics3,
    :basics4,
    :basics5,
    :basics6,
    :blockless_column_definition,
    :buttons,
    :csv_and_detached_filters,
    :csv_export,
    :custom_filter_params,
    :custom_filters1,
    :custom_filters2,
    :custom_filters3,
    :custom_filters4,
    :custom_ordering,
    :custom_ordering_on_calculated,
    :custom_ordering_with_arel,
    :custom_ordering_with_proc,
    :custom_ordering_with_ruby,
    :dates,
    :detached_filters,
    :detached_filters_two_grids,
    :disable_all_filters,
    :erb_mode,
    :integration_with_application_view,
    :integration_with_forms,
    :joining_tables,
    :localization,
    :many_grids_on_page,
    :negation,
    :no_records,
    :null_values,
    :numeric_filters,
    :resultset_processings,
    :resultset_processings2,
    :saved_queries,
    :styling,
    :tasks,
    :two_associations,
    :upper_pagination_panel,
    :when_filtered,
  )

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
