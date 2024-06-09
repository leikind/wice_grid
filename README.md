[![Version](http://img.shields.io/gem/v/wice_grid.svg)](https://rubygems.org/gems/wice_grid)
[![CircleCI](https://circleci.com/gh/patricklindsay/wice_grid.svg?style=svg)](https://circleci.com/gh/patricklindsay/wice_grid)
[![Inline docs](http://inch-ci.org/github/patricklindsay/wice_grid.svg)](http://inch-ci.org/github/patricklindsay/wice_grid)
[![License](http://img.shields.io/badge/license-MIT-yellowgreen.svg)](#license)

# WiceGrid

- [Intro](#intro)
- [Requirements and Rails versions](#requirements-and-rails-versions)
- [Installation](#installation)
- [Basics](#basics)
  - [Rendering filter panel](#rendering-filter-panel)
  - [Initial Ordering](#initial-ordering)
  - [Records Per Page](#records-per-page)
  - [Conditions](#conditions)
  - [Queries with join tables](#queries-with-join-tables)
  - [Joined associations referring to the same table](#joined-associations-referring-to-the-same-table)
  - [More than one grid on a page](#more-than-one_grid-on-a-page)
  - [Custom Ordering](#custom-ordering)
  - [Custom Sorting](#custom-sorting)
- [Filters](#filters)
  - [Custom dropdown filters](#custom-dropdown-filters)
  - [Numeric Filters](#numeric-filters)
  - [Date and DateTime Filters](#date-and-datetime-filters)
  - [Detached Filters](#detached-filters)
- [Defaults](#defaults)
- [Testing](#testing)
- [Bug reports](#bug-reports)


## Intro

WiceGrid is a Rails grid plugin.

One of the goals of this plugin was to allow the programmer to define the contents of the cell on their
own, just like one does when rendering a collection via a simple table (and this is what differentiates
WiceGrid from various scaffolding solutions), but automate implementation of filters, ordering,
paginations, CSV export, and so on. Ruby blocks provide an elegant means for this.


WiceGrid builds the call to the ActiveRecord layer for you and creates a table view with the results
of the call including:

* Pagination
* Sortable columns
* Filtering by multiple columns
* Export to CSV
* Saved queries

Filters are added automatically according to the type of the underlying DB column. Filtering by more
than one column at the same time is possible. More than one such grid can appear on a page, and
manipulations with one grid do not have any impact on others.

WiceGrid does not take a collection as an input, it works directly with ActiveRecord.

WiceGrid does not use XHR calls to reload itself, instead simple GET requests are used for this,
nevertheless, all other page parameters are respected and preserved. WiceGrid works well with Turbolinks.

WiceGrid views do not contain forms so you can include it in your own forms.

WiceGrid is known to work with MySQL, Postgres, and Oracle.

Continue reading for more information or check out our [CHANGELOG](https://github.com/patricklindsay/wice_grid/blob/master/CHANGELOG.md) to find out whats been going on.


## Requirements and Rails versions

```
# Rails 5, 6, and 7.0 without importmap (see below)
gem 'wice_grid', '~> 6.1'

# Rails 4
gem 'wice_grid', '3.6.2'
```

WiceGrid relies on jQuery and coffeescript. So the current version will not work with Rails 7, that uses gem `importmap-rails`. But if your application allows the javascript transpiling the gem should work.

The development of the version of WiceGrid that works with Ruby 7.1 and higher is in progress.

If you need a JS Datepicker, WiceGrid supports jQuery Datepicker or
[Bootstrap Datepicker](https://github.com/Nerian/bootstrap-datepicker-rails), so you might need one of
those. See section Installation for details on how to use datepickers.

WARNING: Since 3.2.pre2 WiceGrid is not compatible with `will_paginate` because internally it uses
`kaminari` for pagination, and `kaminari` is not compatible with `will_paginate`!


## Installation

Add the following to your Gemfile & run `bundle`:

```ruby
gem "wice_grid"
```

Note: `font-awesome-sass` is not a dependency of WiceGrid in case you decide to style WiceGrid icons differently.

Run the generator:

```
rails g wice_grid:install
```

This adds the following file:
* `config/initializers/wice_grid_config.rb`


Require WiceGrid javascript in your js index file:

```
//= require wice_grid
```

Make sure jQuery is loaded. If the application uses Date and DateTime filters, you have to install
jQuery Datepicker by yourself. You can also use
[Bootstrap Datepicker](https://github.com/Nerian/bootstrap-datepicker-rails).

Here is an example of `application.js` if jquery.ui.datepicker is used:

```
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require wice_grid
//= require jquery.ui.datepicker
//= require_tree .
```

Here is `application.js` if [Bootstrap Datepicker](https://github.com/Nerian/bootstrap-datepicker-rails) is used:

```
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require wice_grid
//= require bootstrap-datepicker
//= require_tree .
```

Require WiceGrid and [Font Awesome](http://fortawesome.github.io/Font-Awesome/) CSS in your `application.scss`:

```
  @import "wice_grid";
  @import "font-awesome-sprockets";
  @import "font-awesome";
```

This will provide very basic styles, not specifying exactly how the table should look like, but if
the application uses Twitter Bootstrap, the markup generated by WiceGrid will have correct classes and
will fit nicely.

WiceGrid uses icons from [Font Awesome](http://fortawesome.github.io/Font-Awesome/).

Should you decide to write you own styles for WiceGrid, you can just remove these imports and write your own styles.


## Basics

The simplest example of a WiceGrid for one simple DB table is the following:

Controller:

```ruby
@tasks_grid = initialize_grid(Task)
```

It is also possible to use an  `ActiveRecord::Relation` instance as the first argument:

```ruby
@tasks_grid = initialize_grid(Task.where(active: true))
```

View:

```erb
<%= grid(@tasks_grid) do |g|

  g.column do |task|
    task.id
  end

  g.column  do |task|
    task.title
  end

  g.column do |task|
    task.description
  end

  g.column do |task|
    task.archived? ? 'Yes' : 'No'
  end

  g.column do |task|
    link_to('Edit', edit_task_path(task))
  end
end -%>
```

Code `g.column do |task| ... end`
defines everything related to a column in the resulting view table including column names, sorting,
filtering, the content of the column cells, etc. The return value of the block is the table cell content.

Column names are defined with parameter `:name`:

```erb
<%= grid(@tasks_grid) do |g|

  g.column name: 'ID' do |task|
    task.id
  end

  g.column name: 'Title'  do |task|
    task.title
  end

  g.column name: 'Description' do |task|
    task.description
  end

  g.column name: 'Archived' do |task|
    task.archived? ? 'Yes' : 'No'
  end

  g.column do |task|
    link_to('Edit', edit_task_path(task))
  end
end -%>
```

To add filtering and ordering, declare to which column in the underlying database table(s) the view
column corresponds using parameter `:attribute`:

```erb
<%= grid(@tasks_grid) do |g|

  g.column name: 'ID', attribute: 'id' do |task|
    task.id
  end

  g.column name: 'Title', attribute: 'title'  do |task|
    task.title
  end

  g.column  name: 'Description', attribute: 'description' do |task|
    task.description
  end

  g.column name: 'Archived', attribute: 'archived' do |task|
    task.archived? ? 'Yes' : 'No'
  end

  g.column do |task|
    link_to('Edit', edit_task_path(task))
  end
end -%>
```

This will  add sorting links and filters for columns `Username` and `Active`. The plugin automatically
creates filters according to the type of the database column. In the above example a text field will be
created for column Title (title is a string), for column `Archived` a dropdown filter will be created
with options 'Yes', 'No', and '--', and for the integer ID two short text fields are added which can
contain the numeric range (more than, less than).

It is important to remember that `:attribute` is the name of the database column, not a model attribute.
Of course, all database columns have corresponding model attributes, but not all model attributes map to
columns in the same table with the same name.

Read more about available filters in the documentation for the column method.

Read the section about custom dropdown filters for more advanced filters.

For columns like

```ruby
g.column name: 'Title', attribute: 'title'  do |task|
  task.title
end
```

where the block contains just a call to the same attribute declared by :attribute, the block can be
omitted:

```erb
<%= grid(@tasks_grid) do |g|

  g.column name: 'ID', attribute: 'id'

  g.column name: 'Title', attribute: 'title'

  g.column name: 'Description', attribute: 'description'

  g.column name: 'Archived', attribute: 'archived' do |task|
    task.archived? ? 'Yes' : 'No'
  end

  g.column  do |task|
    link_to('Edit', edit_task_path(task))
  end
end -%>
```

In this case `name` will be used as the method name to send to the ActiveRecord instance.

If only ordering is needed, and no filter, we can turn off filters using `:filter` :

```ruby
g.column name: 'ID', attribute: 'id', filter: false
```

If no ordering links are needed, use `ordering: false`:

```ruby
g.column name: 'Added', attribute: 'created_at', ordering: false
```

It is important to understand that it is up to the developer to make sure that the value returned by a
column block (the content of a cell) corresponds to the underlying database column specified by
`:attribute` (and `:assoc` discussed below).


### Rendering filter panel

The filter panel can be shown and hidden clicking the icon with binoculars.

The way the filter panel is shown after the page is loaded is controlled via parameter
`:show_filters` of the `grid` helper.
Possible values are:

* `:when_filtered` - the filter is shown when the current table is the result of filtering
* `:always` - always show the filter
* `:no` - never show the filter

Example:

```erb
<%= grid(@tasks_grid, show_filters: :always) do |g|
  ......
end -%>
```

Filter related icons (filter icon, reset icon, show/hide icon) are placed in the header of the last
column if it doesn't have any filter or a column name, otherwise an additional table column is added.
To always place the icons in the additional column, set
`Wice::Defaults::REUSE_LAST_COLUMN_FOR_FILTER_ICONS` to `false` in the configuration file.


### Initial ordering

Initializing the grid we can also define the column by which the record will be ordered <em>on the first
rendering of the grid</em>, when the user has not set their ordering setting by clicking the column label,
and the order direction:

```ruby
@tasks_grid = initialize_grid(Task,
  order:           'tasks.title',
  order_direction: 'desc'
)
```

### Records per page

The number of rows per page is set with `:per_page`:

```ruby
@tasks_grid = initialize_grid(Task, per_page: 40)
```

### Conditions

The `initialize_grid` method supports a `:conditions` parameter which is passed on to the underlying
ActiveRecord, so it can be in any format processable by ActiveRecord:

```ruby
@tasks_grid = initialize_grid(Task,
  conditions: ["archived = false and estimated_time > ?", 100]
)

@tasks_grid = initialize_grid(Task,
  include:    :project,
  conditions: {archived: false, project: {active: true}}
)
```

A good example is substituting a common pattern like

```ruby
@user_groups = @portal_application.user_groups
```

with WiceGrid code:

```ruby
@user_groups_grid = initialize_grid(
  UserGroup,
  conditions: ['portal_application_id = ?', @portal_application]
)
```

Alternatively, instead of a Class object as the first parameter, you can use  ActiveRecord::Relation:

```ruby
@tasks_grid = initialize_grid(
  Task.where(archived: false, projects: {active: true}).joins(:project)
)
```

Please note that though all queries inside of WiceGrid are run without the default scope, if you use an
ActiveRecord::Relation instance to initialize grid, it will already include the default scope. Thus you
might consider using `unscoped`:

```ruby
@tasks_grid = initialize_grid(
  Task.unscoped.where(archived: false, projects: {active: true}).joins(:project)
)
```

### Queries with join tables

To join other tables, use `:include`:

```ruby
@products_grid = initialize_grid(Product,
  include:  :category,
  order:    'products.name',
  per_page: 20
)
```

The value of `:include` can be an array of association names:

```ruby
include:  [:category, :users, :status]
```

If you need to join tables to joined tables, use hashes:


```ruby
include:  [:category, {users: :group}, :status]
```


Note that if we want to order initially by a column from a joined table we have to specify the table and
the column name with the sql dot notation, that is, `products.name`.

To show columns of joined tables in the view table, specify the corresponding association with `:assoc`:

```erb
<%= grid(@products_grid) do |g|
  g.column name: 'Product Name', attribute: 'name' do |product|  # primary table
    link_to(product.name, product_path(product))
  end

  g.column name: 'Category', attribute: 'name', assoc: :category do |product| # joined table
    product.category.name
  end
%>
```

Please note that the blockless definition of the column can also be used with joined tables:

```
g.column name: 'Category', attribute: 'name', assoc: :category

```

If an association is mentioned in the column definition, it can be omitted from `:include` in `initialize_grid`.
Thus, the above example can be rewritten without `:category` in `:include`:


```ruby
@products_grid = initialize_grid(Product,
  order:    'products.name',
  per_page: 20
)
```

```erb
<%= grid(@products_grid) do |g|
  g.column name: 'Product Name', attribute: 'name' do |product|  # primary table
    link_to(product.name, product_path(product))
  end

  g.column name: 'Category', attribute: 'name', assoc: :category

%>
```

### Joined associations referring to the same table

In case there are two joined associations both referring to the same table, ActiveRecord constructs a query
where the second join provides an alias for the joined table. To enable WiceGrid to order and filter by
columns belonging to different associations but originating from the same table, set `:table_alias`
to this alias:

Model:

```ruby
 class Project < ActiveRecord::Base
   belongs_to :customer, class_name: 'Company'
   belongs_to :supplier, class_name: 'Company'
 end
```

Controller:

```ruby
@projects_grid = initialize_grid(Project)
```

View:

```erb
<%= grid(@projects_grid, show_filters: :always) do |g|

  g.column name: 'Project Name', attribute: 'name'

  g.column name: 'Customer company', assoc: :customer, attribute: 'name'

  g.column name: 'Supplier company', assoc: :supplier, attribute: 'name', table_alias: 'suppliers_projects'

end -%>
```

### More than one grid on a page

It is possible to use more that one grid on a page, each with its own state. To do so, you must specify the
name of the grid in `initialize_grid` using parameter `:name`.

The name serves as the base name for HTTP parameters, DOM IDs, etc, so it is important that all grids on a
page have different names. The default name is 'grid'.

The name can only contain alphanumeric characters.

```ruby
@projects_grid = initialize_grid(Project, name: 'g1')
@tasks_grid    = initialize_grid(Task,    name: 'g2')
```

### Custom Ordering

It is possible to change the way results are ordered injecting a chunk of SQL code, for example, use
`ORDER BY INET_ATON(ip_address)` instead of `ORDER BY ip_address`.

To do so, provide parameter `:custom_order` in the initialization of the grid with a `Hash` where
keys are fully qualified names of database columns, and values are anything that can be passed to ActiveRecord's
`order` method (without specifying `ASC` or `DESC`.)

#### String

Starting in Rails 5.2, you may need to whitelist `String` values with `Arel.sql`
to avoid a warning or error.

```ruby
@hosts_grid = initialize_grid(Host,
  custom_order: {
    'hosts.ip_address' => Arel.sql('INET_ATON(hosts.ip_address)')
  })
```

It is possible to use `?` instead of the name of the column in the `Hash` value:

```ruby
@hosts_grid = initialize_grid(Host,
  custom_order: {
    'hosts.ip_address' => Arel.sql('INET_ATON( ? )')
  })
```

#### Arel::Attributes::Attribute

Assuming you wish to display `hosts.ip_address` but sort by another column named `hosts.ip_address_number`:

```ruby
@hosts_grid = initialize_grid(Host,
  custom_order: {
    'hosts.ip_address' => Arel::Table.new(:hosts)[:ip_address_number]
  })
```

#### Proc

You can use a `Proc` to return a `String` or `Arel::Attributes::Attribute` as above.

```ruby
@hosts_grid = initialize_grid(Host,
  custom_order: {
    'hosts.ip_address' => lambda{|f| Arel.sql(request[:numeric_sorting] ? "INET_ATON( #{f} )" : f) }
  })
```

### Custom Sorting

While `:custom_order` lets you define SQL that determines the results order, you may want to sort the result by arbritrary Ruby code. The `:sort_by` option on columns lets you define a `Proc` that determines the sorting on that column. This `Proc` is passed to Ruby's `Enumerable#sort_by`.

```ruby
grid.column name:  'Status Name', attribute: 'name', sort_by: ->(status) { [status.number_of_vowels, status] }
```

You can also use `:sort_by` to add sorting on values that are not columns in the database. In this case, you must also define an arbitrary `:attribute` option that serves as the request's sort key parameter.

```ruby
grid.column name: 'Task Count', attribute: 'task_count', sort_by: ->(status) { status.tasks.count } do |status|
  status.tasks.count
end
```

Note that `sort_by` will load all records into memory to sort them (even the ones not on the current page), so it may not be appropriate for use with a large number of results.

## Filters

Each column filter type is supported by a `column processor`. Each `column processor` is
responsible for

* generating HTML and supporting Javascript for the filter, input fields, dropdowns, javascript calendars, etc
* converting HTTP parameters from those input fields into ActiveRelation instances

By default column filters depend on the type of the underlying database column.

You can override these defaults in two ways:

* defining a custom filter with `:custom_filter`. Read more about it section "Custom dropdown filters".
* overriding the `column processor` type with `:filter_type`.

Which Column Processor is instantiated for which data types is defined in file
`lib/wice/columns/column_processor_index.rb`:

```ruby
module Wice
  module Columns
    COLUMN_PROCESSOR_INDEX = ActiveSupport::OrderedHash[ #:nodoc:
      :action,                 'column_action',                # Special processor for action column, columns with checkboxes
      :text,                   'column_string',
      :string,                 'column_string',
      :rails_datetime_helper,  'column_rails_datetime_helper', # standard Rails datepicker helper
      :rails_date_helper,      'column_rails_date_helper',     # standard Rails date helper
      :jquery_datepicker,      'column_jquery_datepicker',
      :bootstrap_datepicker,   'column_bootstrap_datepicker',
      :html5_datepicker,       'column_html5_datepicker',      # not ready
      :integer,                'column_integer',
      :range,                  'column_range',
      :float,                  'column_float',
      :decimal,                'column_float',
      :custom,                 'column_custom_dropdown',       # Special processor for custom filter columns
      :boolean,                'column_boolean'
    ]
  end
end
```

A good example for using `:filter_type` to change th default is numeric columns. By default
`'column_integer'` is instantiated for `integer` columns, and it renders one input field.
But it is also possible to use another Column Processor called `'column_range'` which renders two
input fields and searches for values in the given the range instead of searching for values which equal
the given search term.

It also possible to define and use your own column processors outside of the plugin, in you application.
Read more about this in section "Defining your own external filter processors".


### Custom dropdown filters

It is possible to construct custom dropdown filters. A custom dropdown filter is essentially a dropdown
list.

Depending on the value of `column` parameter`:custom_filter` different modes are available:


#### Array of two-element arrays or a hash

An array of two-element arrays or a hash are semantically identical ways of creating a custom filter.

Every first item of the two-element array is used for the label of the select option while the second
element is the value of the select option. In case of a hash the keys become the labels of the generated
dropdown list, while the values will be values of options of the dropdown list:

```ruby
g.column name: 'Status', attribute: 'status',
         custom_filter: {'Development' => 'development', 'Testing' => 'testing', 'Production' => 'production'}

g.column name: 'Status', attribute: 'status',
        custom_filter: [['Development', 'development'], ['Testing', 'testing'], ['Production', 'production']]
```

It is also possible to submit a array of strings or numbers, in this case every item will be used both as
the value of the select option and as its label:

```ruby
g.column name: 'Status', attribute: 'status', custom_filter: ['development', 'testing', 'production']
```

#### :auto

`:auto` - a powerful option which populates the dropdown list with all unique values of the column
specified by `:attribute` and `:assoc`, if present.

```ruby
g.column name: 'Status', attribute: 'status', custom_filter: :auto
```

In the above example all statuses will appear in the dropdown even if they don't appear in the current
resultset.


#### Custom filters and associations (joined tables)

In most cases custom fields are needed for one-to-many and many-to-many associations.

To correctly build a filter condition foreign keys have to be used, not the actual values rendered in the
column.

For example, if there is a column:

```ruby
g.column name: 'Project Name', attribute: 'name', assoc: :project do |task|
  task.project.name if task.project
end
```

adding `:custom_filter` like this:

```ruby
g.column name: 'Project Name', attribute: 'name', assoc: :project,
         custom_filter: Project.find(:all).map{|pr| [pr.name, pr.name]} do |task|
  task.project.name if task.project
end
```

is bad style and can fail, because the resulting condition will compare the name of the project,
`projects.name` to a string, and in some databases it is possible that different records
(projects in our example) have the same name.

To use filter with foreign keys, it is advised to change the declaration of the column from
`projects.name`, to `tasks.project_id`, and build the dropdown with foreign keys as values:

```ruby
g.column name: 'Project Name', attribute: 'tasks.project_id',
         custom_filter: Project.find(:all).map{|pr| [pr.id, pr.name]} do |task|
  task.project.name if task.project
end
```

However, this will break the ordering of the column - the column will be ordered by the integer foreign
key. To fix this, we can override the ordering using `:custom_order`:

```ruby
@tasks_grid = initialize_grid(Task,
  include: :project,
  custom_order: {
    'tasks.project_id' => 'projects.name'
  }
)
```

#### Any other symbol (method name) or an array of symbols (method names)


For one symbol (different from `:auto`) the dropdown list is populated by all unique values returned
by the method with this name sent to <em>all</em> ActiveRecord objects throughout all pages.

The conditions set up by the user are ignored, that is, the records used are all those found on all pages
without any filters active.

For an array of symbols, the first method name is sent to the ActiveRecord object if it responds to this
method, the second method name is sent to the returned value unless it is `nil`, and so on. In other
words, a single symbol mode is the same as an array of symbols where the array contains just one element.

```ruby
g.column name: 'Version', attribute: 'expected_version_id', custom_filter: [:expected_version, :to_option] do |task|
  task.expected_version.name if task.expected_version
end
```

There are two important differences from `:auto`:

1. The  method does not have to be a field in the result set, it is just some  value computed in the method after the database call and ActiveRecord instantiation.
2. Filtering by any option of such a custom filter will bring a non-empty list, unlike with `:auto`.


This mode has one major drawback - this mode requires an additional query without `offset` and `limit`
clauses to instantiate _all_ ActiveRecord objects, and performance-wise it brings all the advantages of
pagination to nothing. Thus, memory- and performance-wise this can be really bad for some queries and
tables and should be used with care.


If the final method returns a atomic value like a string or an integer, it is used for both the value and
the label of the select option element:

```html
<option value="returned value">returned value</option>
```

However, if the retuned value is a two element array, the first element is used for the option label and
the second - for the value.

Typically, a model method like the following:

```ruby
def to_option
  [name, id]
end
```

together with

```ruby
custom_filter:  :to_option
```

would do the trick:

```html
<option value="id">name</option>
```

Alternatively, a hash with the single key-value pair can be used, where the key will be used for the
label, and the key - for the value:

```ruby
def to_option
  {name => id}
end
```

#### Special treatment of values 'null' and 'not null'

Values `null` and `not null` in a generated custom filter are treated specially, as  SQL `null` statement
and not as strings. Value `null` is transformed into SQL condition `IS NULL`, and `not null` into
`IS NOT NULL`.

Thus, if in a filter defined by

```ruby
custom_filter: {'No' => 'null', 'Yes' => 'not null', '1' => 1, '2' => '2', '3' => '3'}
```

values '1', '2' and 'No' are selected (in a multi-select mode),  this will result in the following SQL:

```sql
( table.field IN ( '1', '2' ) OR table.field IS NULL )
```

#### Multiple selection

By default it is possible for any dropdown list to switch between single and multiple selection modes.
To only allow single selection use `:allow_multiple_selection`:

```ruby
g.column name: 'Expected in version', attribute: 'expected_version_id',
       custom_filter: [:expected_version, :to_option], allow_multiple_selection: false do |task|
  ...
end
```

### Numeric Filters

Before version 3.2.1 the filter used for numeric columns was a range filter with two limits. Beginning
with version  3.2.1 the default is a direct comparison filter with one input field. The old range filter
can still be loaded using parameter `:filter_type` with value `:range`:

```ruby
g.column filter_type: :range do |task|
  ...
end
```

### Date and DateTime Filters

WiceGrid provides four filters for selecting dates and time:

  * ```:jquery_datepicker``` - Jquery datepicker (works for datetime, too)
  * ```:bootstrap_datepicker``` - Bootstrap datepicker (works for datetime, too)
  * ```:rails_date_helper``` - standard Rails date helper
  * ```:rails_datetime_helper``` - standard Rails datetime helper

Specify a date/datetime filter just like you specify any other filter:

```
  g.column name:  'Updated', attribute: 'updated_at', filter_type: :rails_datetime_helper do |task|
    task.updated_at.to_s(:db)
  end
```

Default filters are defined in configuration constants Wice::Defaults::DEFAULT_FILTER_FOR_DATE and
Wice::Defaults::DEFAULT_FILTER_FOR_DATETIME.



#### jQuery UI DatePicker `(HELPER_STYLE = :calendar)`

By default WiceGrid uses jQuery UI datepicker[http://jqueryui.com/demos/datepicker/] for Date and DateTime
filters. Because this is part of the standard jQuery UI codebase, it is not bundled together with the
plugin, and it is the responsibility of the programmer to include all necessary assets including
localization files if the application is multilingual.

jQuery UI datepicker does not have any time related controls, and when dealing with DateTime filters, the
time value is ignored.

Constants `DATE_FORMAT` and `DATETIME_FORMAT` in the configuration file define the format of dates the
user will see, as well as the format of the string sent in a HTTP parameter. If you change the formats,
make sure that lamdbas defined in `DATETIME_PARSER` and `DATE_PARSER` return valid DateTime and Date
objects.

jQuery `datepicker` uses a different format flavor, therefore there is an additional constant
`DATE_FORMAT_JQUERY`. While `DATE_FORMAT_JQUERY` is fed to `datepicker`, `DATE_FORMAT` is still used
for presenting initial date values in filters, so make sure that `DATE_FORMAT_JQUERY` and `DATE_FORMAT`
result in an identical date representation.

Constant `DATEPICKER_YEAR_RANGE` defines the range of years in the Datepicker year dropdown. Alternatively,
you can always change this range dynamically with the following javascript:

```js
$( ".hasDatepicker" ).datepicker( "option", "yearRange", "2000:2042" );
```

#### jQuery UI DatePicker `(HELPER_STYLE = :bootstrap)`

WiceGrid also supports [Bootstrap Datepicker](https://github.com/Nerian/bootstrap-datepicker-rails).

#### Rails standard input fields `(HELPER_STYLE = :standard)`

Another option is standard Rails helpers for date fields, these are separate select fields for years,
months and days (also for hour and minute if it is a datetime field).

### Detached Filters

Filters can also be detached from the grid table and placed anywhere on page.

This is a 3-step process.

First, define the grid with helper `define_grid` instead of `grid`. Everything should be done the same way
as with `grid`, but every column which will have an external filter, add
`detach_with_id: :some_filter_name`` in the column definition. The value of `:detach_with_id` is an
arbitrary string or a symbol value which will be used later to identify the filter.

```erb
<%= define_grid(@tasks_grid, show_filters: :always) do |g|

  g.column name: 'Title', attribute: 'title', detach_with_id: :title_filter do |task|
    link_to('Edit', edit_task_path(task.title))
  end

  g.column name: 'Archived', attribute: 'archived', detach_with_id: :archived_filter do |task|
    task.archived? ? 'Yes' : 'No'
  end

  g.column name: 'Added', attribute: 'created_at', detach_with_id: :created_at_filter do |task|
    task.created_at.to_s(:short)
  end

end -%>
```

Then, use `grid_filter(grid, :some_filter_name)` to render filters:

```erb
<% # rendering filter with key :title_filter %>
<%= grid_filter @tasks_grid, :title_filter  %>

<% # rendering filter with key :archived_filter %>
<%= grid_filter @tasks_grid, :archived_filter  %>

<% # rendering filter with key :created_at_filter %>
<%= grid_filter @tasks_grid, :created_at_filter  %>

<% # Rendering the grid body %>
<%= grid(@tasks_grid) %>
```

Finally, use `render_grid(@grid)` to actually output the grid table.


Using custom submit and reset buttons together with `hide_submit_button: true` and
`hide_reset_button: true` allows to completely get rid of the default filter row and the default
icons (see section 'Submit/Reset Buttons').


If a column was declared with `:detach_with_id`, but never output with `grid_filter`, filtering
the  grid in development mode will result in an warning javascript message and the missing filter will be
ignored. There is no such message in production.


### Defining your own external filter processors


It possible to define and use your own column processors outside of the plugin, in you application.

The first step is to edit `Wice::Defaults::ADDITIONAL_COLUMN_PROCESSORS` in
`wice_grid_config.rb`:

```ruby

Wice::Defaults::ADDITIONAL_COLUMN_PROCESSORS = {
  my_own_filter:    ['ViewColumnMyOwnFilter',   'ConditionsGeneratorMyOwnFilter'],
  another_filter:   ['ViewColumnAnotherFilter', 'ConditionsGeneratorAnotherFilter']
}
```

The first element in the two-item array is the name of a class responsible for rendering
the filter view. The second element  is the name of a class responsible for processing
filter parameters.

For examples of these two classes look at the existing column processors in `lib/wice/columns/`

The structure of these two classes is as follows:

```ruby
class ViewColumnMyOwnFilter < Wice::Columns::ViewColumn

  def render_filter_internal(params)
    ...
  end

  def yield_declaration_of_column_filter
    {
      templates:  [...],
      ids:        [...]
    }
  end
end


class ConditionsGeneratorMyOwnFilter < Wice::Columns::ConditionsGeneratorColumn

  def generate_conditions(table_name, opts)
    ...
  end

end
```

To use an external column processor use `:filter_type` in a column definition:

```ruby
column name: 'name', attribute: 'attribute', filter_type: :my_own_filter do |rec|
  ...
end
```

## Defaults

Default values like  can be  changed in `config/initializers/wice_grid_config.rb`.

## Submit/Reset buttons
Instead of using default Submit and Reset icons you can use external HTML elements to trigger
these actions. Add a button or any other clickable HTML element with class
`wg-external-submit-button` or `wg-external-reset-button`, and attribute `data-grid-name`
whose value is the name of the grid:

```html
<button class="wg-external-submit-button" data-grid-name="grid">Submit</button>
<button class="wg-external-reset-button" data-grid-name="grid">Reset</button>
```

To hide the default icons use `hide_submit_button: true` and
`hide_reset_button: true` in the `grid` helper.


## Auto-reloading filters

It is possible to configure a grid to reload itself once a filter has been changed. It works with all
filter types including the JS calendar, the only exception is the standard Rails date/datetime filters.

Use option `:auto_reload` in the column definiton:

```erb

<%= grid(@tasks_grid, show_filters: :always, hide_submit_button: true) do |g|

  # String
  g.column name: 'Title', attribute: 'title', auto_reload: true

  # Boolean
  g.column name: 'Archived', attribute: 'archived', auto_reload: true

  # Custom (dropdown)
  g.column name: 'Status', attribute: 'status_id', custom_filter: Status.to_dropdown, auto_reload: true  do |task|
    task.status.name if task.status
  end

  # Datetime
  g.column name: 'Added', attribute: 'created_at', auto_reload: true, helper_style: :calendar do |task|
    task.created_at.to_s(:short)
  end

end -%>
```

To make this  behavior default change constant `AUTO_RELOAD` in the configuration file.

## Styling the grid


### Adding classes and styles

The `grid` helper accepts parameter `:html` which is a hash of HTML attributes for the table tag.

Another `grid` parameter is `header_tr_html` which is a hash of HTML attributes to
be added to the first `tr` tag (or two first `tr`'s if the filter row is present).

`:html` is a parameter for the `column` method setting HTML attributes of `td` tags for a certain column.

### Adding classes and styles dynamically

WiceGrid offers ways to dynamically add classes and styles to `TR` and `TD` based on the current ActiveRecord instance.


For `<TD>`, let the `column` return an array where the first item is the usual
string output whole the second is a hash of HTML attributes to be added for the
`<td>` tag of the current cell:

```ruby
g.column  do |portal_application|
  css_class = portal_application.public? ? 'public' : 'private'
  [portal_application.name, {class: css_class}]
end
```

For adding classes/styles to `<TR>` use special clause  `row_attributes` ,
similar to `column`, only returning a hash:

```erb
<%= grid(@versions_grid) do |g|
  g.row_attributes do |version|
    if version.in_production?
      {style: 'background-color: rgb(255, 255, 204);'}
    end
  end

  g.column{|version| ... }
  g.column{|version| ... }
end  -%>
```

Naturally, there can be only one `row_attributes` definition for a WiceGrid instance.

Various classes do not overwrite each other, instead, they are concatenated.


## Adding rows to the grid

It is possible to add your own handcrafted HTML after and/or before each grid row.
This works similar to `row_attributes`, by adding blocks `after_row`, `before_row`,  and `last_row`:

```erb
<%= grid(@tasks_grid) do |g|
  g.before_row do |task, number_of_columns|
    if task.active?
      "<tr><td colspan=\"10\">Custom line for #{t.name}</td></tr>"  # this would add a row
                                                                    # before every active task row
    else
      nil
    end
  end

  g.last_row do |number_of_columns|         # This row will always be added to the bottom of the grid
    content_tag(:tr,
      content_tag(:td,
        'Last row',
      colspan: 10),
     class: 'last_row')
  end

  .......
end %>
```

It is up for the developer to return the correct HTML code, or return `nil` if no row is needed for this record.
Naturally, there is only one `before_row`  definition and one `after_row` definition for a WiceGrid instance.

The second variable injected into to `before_row` and `after_row` block, and the first parameter injected
into the `last_row` is the number of columns in the current grid.

## Rendering a grid without records

If the grid does not contain any records to show, it is possible show some alternative view instead of
an empty grid. Bear in mind that if the user sets up the filters in such a way that the selection of
records is empty, this will still render the grid and it will be possible to reset the grid clicking
 on the Reset button. Thus, this only works if the initial number of records is 0.

```erb
<%= grid(@grid) do |g|

  g.blank_slate  do
    "There are no records"
  end

  g.column  do |product|
     ...
  end
 end  -%>
```

There are two alternative ways to do the same, submitting a string to `blank_slate`:

```ruby
g.blank_slate "some text to be rendered"
```

Or a partial:

```ruby
g.blank_slate partial: "partial_name"
```

## Action Column

It is possible to add a column with checkboxes for each record. This is useful for actions with multiple records,
for example, deleting selected records. Please note that `action_column` only creates the checkboxes and the
'Select All' and 'Deselect All' buttons, and the form itself as well as processing the parameters should be
taken care of by the application code.

```erb
<%= grid(@tasks_grid, show_filters: :always) do |g|

  ...

  g.action_column

  ...

end -%>
```

By default the name of the HTTP parameter follows pattern `"#{grid_name}[#{param_name}][]"`, thus
`params[grid_name][param_name]` will contain an array of object IDs.

You can hide a certain action checkbox if you add the usual block to `g.action_column`, just like with the
`g.column` definition. If the block returns `nil` or `false` no checkbox will be rendered.

```erb
<%= grid(@tasks_grid, show_filters: :always) do |g|

  ...

  g.action_column do |task|
    task.finished?
  end

  ...

end -%>
```

WiceGrid is form-friendly: submitting grid in a form retains the state of the form.



## Integration of the grid with other forms on page

Imagine that the user should be able to change the behavior of the grid using some other control
on the page, and not a grid filter.

For example, on a page showing tasks, change between 'Show active tasks' to 'Show archived tasks' using a dropdown box.
WiceGrid allows to keep the status of the grid with all the filtering and sorting using helper
`dump_filter_parameters_as_hidden_fields` which takes a grid object and dumps
all current sorting and filtering parameters as hidden fields. Just include
`dump_filter_parameters_as_hidden_fields(@grid)` inside your form, and the newly rendered grid will keep ordering and filtering.

```erb
<% form_tag('', method: :get) do %>
  <%= dump_filter_parameters_as_hidden_fields(@tasks_grid) %>
  <%= select_tag 'archived',
     options_for_select([['View active tasks', 0], ['View archived tasks', 1]], @archived ? 1 : 0),
    onchange: 'this.form.submit()' %>
<% end -%>
```


## Show All Records

It is possible to switch to the All Records mode clicking on link "show all" in the bottom right corner.
This functionality should be used with care. To turn this mode off for all grid instances,
change constant `ALLOW_SHOWING_ALL_RECORDS` in `config/initializers/wice_grid_config.rb` to
`false`. To do so for a specific grid, use initializer parameter `:allow_showing_all_records`.

Configuration constant `START_SHOWING_WARNING_FROM` sets the threshold number of all records after
which clicking on the link results in a javascript confirmation dialog.


## CSV Export

It is possible to export the data displayed on a grid to a CSV file. The dumped data is the current resultset
with all the current filters and sorting applied, only without the pagination constraint (i.e. all pages).

To enable CSV export add parameters `enable_export_to_csv` and `csv_file_name` to the initialization of the grid:

```ruby
@projects_grid = initialize_grid(Project,
  include:              [:customer, :supplier],
  name:                 'g2',
  enable_export_to_csv: true,
  csv_file_name:        'projects'
)
```

`csv_file_name` is the name of the downloaded file. This parameter is optional, if it is missing, the name of
the grid is used instead. The export icon will appear at the bottom right corner of the grid. If the program you are importing the generated CSV into has problem processing UTF-8, you can change the character encoding using the `csv_encoding` option. P.e. setting `csv_encoding: 'CP1252:UTF-8'` will make older versions of Excel happy. The format used is `<output encoding>:<input encoding>`.

Next, each grid view helper should be placed in a partial of its own, requiring it from the master
template for the usual flow. There must be no HTML or ERB code in this partial except for the grid helper.

By convention the name of such a partial follows the following pattern:

```
  _GRID_NAME_grid.html.erb
```

In other words, a grid named `tasks` is expected to be found in a template called
`_tasks_grid.html.erb` (remember that the default name of grids is '`grid`'.)

Next, method `export_grid_if_requested` should be added to the end of each action
containing grids with enabled CSV export.

`export_grid_if_requested` intercepts CSV export requests and evaluates the partial with the required grid helper.

The naming convention for grid partials can be easily overridden by supplying a hash parameter
to `export_grid_if_requested` where each key is the name of a grid, and the value is the name of
the template (like it is specified for `render`, i.e. without '_' and extensions):

```ruby
  export_grid_if_requested('g1' => 'tasks_grid', 'g2' => 'projects_grid')
```

If the request is not a CSV export request, `export_grid_if_requested` does nothing and returns
`false`, if it is a CSV export request, the method returns `true`.


If the action has no explicit `render` call, it's OK to just place `export_grid_if_requested`
as the last line of the action:

```ruby
def index

  @tasks_grid = initialize_grid(Task,
    name:                 'g1',
    enable_export_to_csv: true,
    csv_file_name:        'tasks'
  )

  @projects_grid = initialize_grid(Project,
    name:                 'g2',
    enable_export_to_csv: true,
    csv_file_name:        'projects'
  )

  export_grid_if_requested
end
```

Otherwise, to avoid double rendering, use the return value of the method to conditionally call your `render` :

```ruby

def index

  ...........

  export_grid_if_requested || render(action: 'my_template')
end
```

It's also possible to supply a block which will be called if no CSV export is requested:

```ruby
def index

  ...........

  export_grid_if_requested do
     render(action: 'my_template')
  end
end
```

If a column has to be excluded from the CSV export,
set `column` parameter `in_csv` to `false`:

```ruby
g.column in_csv: false do |task|
  link_to('Edit', edit_task_path(task))
end
```

If a column must appear both in HTML and CSV, but with different output, duplicate the column and use
parameters `in_csv` and `in_html` to include one of them to  html output only, the other to CSV only:

```ruby
# html version
g.column name: 'Title', attribute: 'title', in_csv: false do |task|
  link_to('Edit', edit_task_path(task.title))
end
# plain text version
g.column name: 'Title', in_html: false do |task|
  task.title
end
```

The default field separator in generated CSV is a comma, but it's possible to override it:

```ruby
@products_grid = initialize_grid(Product,
  enable_export_to_csv:  true,
  csv_field_separator:   ';',
  csv_file_name:         'products'
)
```

If you need an external CSV export button , add class `wg-external-csv-export-button`
to any clickable element on page and set its attribute `data-grid-name` to the name of the grid:

```html
<button class="wg-external-csv-export-button" data-grid-name="grid">Export To CSV</button>
```

If you need to disable the default export icon in the grid, add `hide_csv_button: true` to the `grid` helper.


## Access to Records From Outside The Grid

There are two ways you can access the records outside the grid - using methods of the WiceGrid
object and using callbacks.

### Accessing Records Via The WiceGrid Object

Method `current_page_records` returns exactly the same list of objects displayed on page:

```erb
<%= grid(@tasks_grid) do |g|
  ...
end -%>

<p>
  IDs of records on the current page:
  <%= @tasks_grid.current_page_records.map(&:id).to_sentence %>
</p>
```

Method `all_pages_records` returns a list of objects browsable through all pages with the current filters:

```erb
<%= grid(@tasks_grid) do |g|
  ...
end -%>

<p>
  IDs of all records:
  <%= @tasks_grid.all_pages_records.map(&:id).to_sentence %>
</p>
```

Mind that this helper results in an additional SQL query.


Because of the current implementation of WiceGrid these helpers work only after the declaration
of the grid in the view.
This is due to the lazy nature of WiceGrid - the actual call to the database is made during
the execution of
the `grid` helper, because to build the correct query columns declarations are required.

### Accessing Records Via Callbacks

It is possible to set up callbacks which are executed from within the plugin just after the call to the database.
The callbacks are called before rendering the grid cells, so the results of this processing can be used in the grid.
There are 3 ways you can set up such callbacks:

Via a lambda object:

```ruby
def index
  @tasks_grid = initialize_grid(Task,
    with_paginated_resultset: ->(records){
      ...
    }
  )
end
```

Via a symbol which is the name of a controller method:

```ruby
def index
  @tasks_grid = initialize_grid(Task,
    with_paginated_resultset: :process_selection
  )
end

def process_selection(records)
  ...
end
```

Via a separate block:

```ruby
def index
  @tasks_grid = initialize_grid(Task)

  @tasks_grid.with_paginated_resultset do |records|
    ...
  end
end
```

There are two callbacks:

* `:with_paginated_resultset` - used to process records of the current page
* `:with_resultset` - used to process all records browsable through all pages with the current filters

While the `:with_paginated_resultset` callback just receives the list of records, `:with_resultset`
receives an ActiveRelation object which can be used to obtain the list of all records:

```ruby
def index
  @tasks_grid = initialize_grid(Task)

  @tasks_grid.with_resultset do |active_relation|
    all_records = active_relation.all
    ...
  end
end
```

This lazy nature exists for performance reasons.
Reading all records leads to an additional call, and there can be cases when processing all records should be triggered
only under certain circumstances:

```ruby
def index
  @tasks_grid = initialize_grid(Task)

  @tasks_grid.with_resultset do |active_relation|
    if params[:process_all_records]
      all_records = active_relation.all
      ...
    end
  end
end
```

## Testing

To run tests:

1. `git clone https://github.com/patricklindsay/wice_grid.git`
2. `cd wice_grid`
3. `bundle`
4. Install phantomjs (e.g. `brew install phantomjs` or `apt-get install phantomjs` or something else)
5. `bundle exec appraisal rspec`

Tests against Rails 5.0, 5.1 & 5.2. To test against a specific version, for example Rails 5.2 run `bundle exec appraisal rails-5.2 rspec`

This repository contains a Rails application for testing purposes. To fire up this application manually, run `cd spec/support/test_app/bin; RAILS_ENV=test rails s`.

## Bug reports

If you discover a problem with Wicegrid, we would love to know about it. Please use the [GitHub issue tracker](https://github.com/patricklindsay/wice_grid/issues)
