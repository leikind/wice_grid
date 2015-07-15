## Saving Queries How-To

WiceGrid allows to save the state of filters as a custom query and later restore it from the list of saved queries.

### Step 1: Create the database table to store queries

To get started create the database table to store queries. Run the following generator:
```
rails g wice_grid:add_migration_for_serialized_queries
```
This add a migration file with the definition of the table. Run the migrate task:
```
  bundle 'rake db:migrate'
```
### Step 2: Create the controller to handle AJAX queries.

Creation and deletion of queries is implemented as AJAX calls, and a controller is needed to handle these calls. Create an empty controller
with any name and add  method +save_wice_grid_queries+ to it:
```
  class QueriesController < ApplicationController
    save_wice_grid_queries
  end
```
This is it. The controller now has the required action methods.

### Step 3: Add routes

If the name of the query controller is QueriesController, add the following to `routes.rb`:
```
  Wice::define_routes(self, 'queries')
```
### Step 4: Add the saved query panel to the view.

To show the list of saved queries and the form to create new queries in a view, add the following helper to the view:
```
  <%= saved_queries_panel(@grid_object) %>
```
Voila!

Just like WiceGrid itself, the query panel contains no forms and is thus form-friendly.

*Important*: Saved queries of all grids in the application are stored in one table and differentiated by the name of the grid, thus, for all forms
with saved queries it is important to define different names! (use parameter `:name` in +initialize_grid+)

It is also possible to initialize a grid with an initial saved query providing the id of the query record or the ActiveRecord
itself to parameter `saved_query`:
```
  @products_grid = initialize_grid(Product,
    name:        'prod_grid',
    saved_query: SavedQuery.find_by_id_and_grid_name(12, 'prod_grid') )
```

## Adding Application Specific Logic to Saving/Restoring Queries

WiceGrid allows to add application specific logic to saving and restoring queries by substituting the default ActiveRecord model provided by WiceGrid with a custom model.

Copy `lib/wice_grid_serialized_query.rb` from the gem to `app/models/`, rename the file and the class to your liking.

After renaming the model to SavedQuery it looks like this:
```
  class SavedQuery < ActiveRecord::Base  #:nodoc:
    serialize :query

    validates_uniqueness_of :name, scope: :grid_name, on: :create,
      message: 'A query with this name already exists'

    validates_presence_of :name, message: 'Please submit the name of the custom query'

    def self.list(name, controller)
      conditions = {grid_name: name}
      self.find(:all, conditions: conditions)
    end
  end
```

It is required that the model provides class method +list+ which accepts two parameters: the name of the WiceGrid instance and the controller
object, and returns a list of queries. The controller object is needed to provide the application context. For instance, if it is needed to
store queries for each user, we could add +user_id+ to the table and modify the code so it looks like the following:
```
  class SavedQuery < ActiveRecord::Base
    serialize :query

    validates_uniqueness_of :name, scope: :grid_name, on: :create,
      message: 'A query with this name already exists'

    validates_presence_of :name, message: 'Please submit the name of the custom query'

    belongs_to :identity # !

    def self.list(name, controller)
      conditions = {grid_name: name}
      if controller.current_user # !
        conditions[:user_id] = controller.current_user.id # provided that method current_user is defined in ApplicationController and returns the currrent user.
      end
      self.find(:all, conditions: conditions)
    end
  end
```

The following step is to make sure that a new query is saved with the correct +user_id+. To do so, change the helper
`saved_queries_panel(@grid_object)` to the following:

```
   <%= saved_queries_panel(@identities_grid, extra_parameters: {user_id: @current_user.id}) %>
```
For every key in has :extra_parameters there must exist a field in the model - this hash will be used as a parameter to
`attributes=` method of the query object.

Finally, let WiceGrid know which model to use for saving queries by changing constant  +QUERY_STORE_MODEL+
in `lib/wice_grid_config.rb` to the name of the custom model (as a string), in the above example this would look like the following:
```
      QUERY_STORE_MODEL = 'SavedQuery'
```
