# 3.6.0

## New API For Joined Tables

Before 3.6.0 `:model_class` was used in column definitions for columns from joined tables.

In 3.6.0 the API has changed to use associations.
If, say, a `Task` `belongs_to` a `Priority`, a column definition should specify this association using `:assoc`:

```ruby
g.column name:  'Priority', attribute: 'name',  assoc: :priority do |task|
  task.priority.name if task.priority
end
```

If, say, a `Task` `belongs_to` a `Project`, and a `Project` belongs to a `Customer`,
`assoc:` should be a list of these associations:

```ruby
g.column name:  'Customer', attribute: 'name', assoc: [:project, :customer]  do |task|
  task.project.customer.name if task.project && task.project.customer
end
```


## Blockless Columns For Joined Tables

Blockless columns used to only work for the main model.
Now they can be used for joined tables, too.

Instead of

```ruby
g.column name:  'Priority', attribute: 'name',  assoc: :priority do |task|
  task.priority.name if task.priority
end
```

you can write

```ruby
g.column name:  'Priority', attribute: 'name',  assoc: :priority
```

Instead of

```ruby
g.column name:  'Customer', attribute: 'name', assoc: [:project, :customer]  do |task|
  task.project.customer.name if task.project && task.project.customer
end
```

you can write

```ruby
  g.column name:  'Customer', attribute: 'name', assoc: [:project, :customer]
```


## New Way To Choose Datepickers

Before 3.6.0 to choose a datepicker type we used `:helper_style` in column definitions and `Wice::Defaults:HELPER_STYLE` in the configuration_file.

In 3.6.0 `:helper_style` and `Wice::Defaults:HELPER_STYLE` are gone.

Now each datepicker is simply a separate filter type, and to pick a datepicker we can use `:filter_type`, just like other filter types are chosen.

Filter types for dates and datetimes are

* `:rails_datetime_helper`
* `:rails_date_helper`
* `:jquery_datepicker`
* `:bootstrap_datepicker`

Example:

```ruby
g.column name:  'Updated', attribute: 'updated_at', filter_type: :rails_datetime_helper do |task|
  task.updated_at.to_s(:db)
end
```

Default filter types for date and datetime columns are set by `Wice::Defaults:DEFAULT_FILTER_FOR_DATE` and `Wice::Defaults:DEFAULT_FILTER_FOR_DATETIME`.


## Icons

There are no more icons inside of the gem. Instead, [Font Awesome](https://github.com/FortAwesome/font-awesome-sass) is used.

## CSS

CSS is no longer copied to the applications asset directory. Instead the user is supposed to add

```sass
@import "wice_grid";
@import "font-awesome-sprockets";
@import "font-awesome";
```

to `application.scss`.

`font-awesome-sass` is not a dependency of WiceGrid in case you decide to style WiceGrid icons differently,
so you need to add it explicitly to your Gemfile:

gem 'font-awesome-sass',  '~> 4.3'



## CI_LIKE

Setting a configuration value in Wice::Defaults::STRING_MATCHING_OPERATORS to CI_LIKE will result in the following SQL generated for string filters:

```sql
UPPER(table.field) LIKE UPPER(?)"
```


## USE_DEFAULT_SCOPE

New `USE_DEFAULT_SCOPE` configuration value from @nathanvda.
By default ActiveRecord calls are always executed inside `Model.unscoped{}`.
Setting `USE_DEFAULT_SCOPE` to `true` will use the default scope for all queries.


# 3.5.0

* In addition to two icons "SET ALL" and "UNSET ALL" in the action column, there is now
  an option to use a standard HTML checkbox. This is now the default.
* Support for Bootstrap Datepicker. A suggested way to use Bootstrap Datepicker in a Rails app
  is https://github.com/Nerian/bootstrap-datepicker-rails. Configuration variable HELPER_STYLE
  sets the default flavor of date pickers. Can also be set per grid with helper_style: :bootstrap
  * :calendar  jQuery UI datepicker
  * :bootstrap Bootstrap datepicker
  * :standard
* Italian locale
* Spanish locale
* various fixes
* Configuration variable ALLOW_SHOWING_ALL_QUERIES renamed to ALLOW_SHOWING_ALL_RECORDS



# 3.4.14

Wice::Defaults::HIDE_ALL_LINK_FROM is nil by default

# 3.4.13

New configuration variable Wice::Defaults::HIDE_ALL_LINK_FROM! When set and the total
number of row exceeds its value, the "SHOW ALL" link disappears.

# 3.4.12

fixes

# 3.4.11

started adding HTML5 datepicker
changed how relations are detected so that it can work with relation proxies (aka octopus)

# 3.4.10

bug fixes
better support for :group

# 3.4.9

better support for Asset Pipeline

bugfixes

dropped support for Ruby 1.8

# 3.4.8

a friendlier exception message when a constant is missing in wice_grid_config.rb

bugfixes

# 3.4.6

Better support for Turbolinks

Better support for ActiveRelation #references

variable Wice::Defaults::PAGE_METHOD_NAME

# 3.4.5

Support for ActiveRelation #references

bugfixes

# 3.4.4

bugfixes

# 3.4.3

bugfixes

# 3.4.2

External columns processors

Operators '<','>','<=','>=','=' in the integer column

Bugfixes

# 3.4.1

Support for Bootstrap 3

# 3.4.0

Support for Rails 4

# 3.3.0

The with_paginated_resultset callback receives an ActiveRelation object, not a lambda

Wice::Defaults::DATEPICKER_YEAR_RANGE added to the config to define the default year range in Datepicker (https://github.com/leikind/wice_grid/issues/61)

Improvement of the javascript calendar control: if the FROM field is set to a value after TO, TO is set to the value of FROM.
Vice versa: if the TO field is set to a value before FROM, FROM is set to the value of TO

New view helpers filter_and_order_state_as_hash(grid) and filter_state_as_hash(grid)

HTML tag caption supported

Support for Ruby 2.0

2 errors fixed in the Saved Queries UI ( https://github.com/leikind/wice_grid/issues/89 )

Bug fixed: extra_request_parameters not propagating to the pagination panel

Documentation improvements

# 3.2.2

improvement of the javascript calendar control: if the FROM field is set to a value after TO, TO is set to the value of FROM.
Vice versa: if the TO field is set to a value before FROM, FROM is set to the value of TO

Wice::Defaults::DATEPICKER_YEAR_RANGE added to the config to define the default year range in Datepicker (https://github.com/leikind/wice_grid/issues/61)

support for Ruby 2.0

<caption> supported

2 js errors fixed in the Saved Queries UI ( https://github.com/leikind/wice_grid/issues/89

helpers filter_and_order_state_as_hash(grid) and filter_state_as_hash(grid)

the with_paginated_resultset callback receives an ActiveRelation object, not a lambda

# 3.2.1

action_column can now also take a block. If the block returns a falsy value, no checkbox will be rendered.

A fix: the css class submitted to column is also added to the <th> tags of the column.

Filter related code has been refactored: condition generators are unified together with view column processors into one module. Writing your own filters has been simplified.

The default filter for numeric columns has been replaced by a simple one field filter which checks the values for equality, not the inclusion in a range.
New column parameter :filter_type allows to load custom alternative filters.
The old numeric range filter can still be used by specifying filter_type: :range. See lib/columns/column_processor_index.rb for the list of available filters.

# 3.2.0

Fixes:
https://github.com/leikind/wice_grid/issues/83
https://github.com/leikind/wice_grid/issues/82

action_column can now also take a block. If the block returns a falsy value, no checkbox will be rendered

A fix: the css class submitted to column is also added to <th> tags of the column

Filter related code has been refactored: condition generators are unified together with view column processors into one module. Writing your own filters has been simplified.

The default filter for numeric columns has been replaced by a simple one field filter which checks the values for equality, not the inclusion in a range.
New column parameter :filter_type allows to load custom alternative filters. The old numeric range filter can still be used by specifying  filter_type: :range.
See lib/columns/column_processor_index.rb</tt> for the list of available filters.


# 3.0.4

bugfixes

# 3.0.3

bugxixes

# 3.0.2

bugxixes

# 3.0.1

Fixed the "Cannot modify SafeBuffer in place" problem and thus Rails # 3.0.8 and # 3.0.9
Support for ActiveRecord::Relation

# 3.0.0

Rails 3 support

0.6

wice_grid_custom_filter_params used to be a view helper, not it is also accessible from the controller, to be used in cases like redirect_to(my_resource_path(wice_grid_custom_filter_params(...)))

auto reloading filters

helper export_to_csv_javascript to create custom CSV buttons

option :hide_csv_button to hide the default CSV export button

Method WiceGrid#selected_records and parameter :after were a bit of a mess and have been substituted by

* WiceGrid#current_page_records returning records on the current page
* WiceGrid#all_pages_records returning records browsable throughout all pages
* :with_paginated_resultset - callback to process records on the current page
* :with_resultset - callback to process records browsable throughout all pages

Compliant with Rails 1.2.8 with or without rails_xss and erubis

Ruby 1.9.1 compliance

Dropdowns generated with :custom_filter => :auto and :custom_filter => [method chain] are now ordered by option labels

how_filters => false is the same as :show_filters => :no and :show_filters => true is the same as :show_filters => :always

action_column - Adds a column with checkboxes for each record.
Useful for actions with multiple records, for example, delete
the selected records.

using merge_conditions to merge conditions :)

WiceGrid is now compatible with the new Rails XSS behavior which
will be the default in Rails # 3.0 and can be used in Rails 2.3.5
using the rails_xss plugin.
Read http://github.com/nzkoz/rails_xss for more

wice_grid_custom_filter_params

support for with_scope and with_exclusive_scope

:total_entries parameter added to initialize_grid (will_paginate)

Localization

assert_keys wherever possible

== 0.5

Today "WiceGrid":http://leikind.org/pages/wicegrid has reached its next level of maturity and was awarded the tag of version 0.5.

This version of WiceGrid is accompanied by an application called _WiceGrid Examples_ running "online":http://grid.leikind.org/ and with source code available on  "GitHub":http://github.com/leikind/wice_grid_examples.

Here's a list of changes as compared with "version 0.4":https://blog.wice.eu/2009/7/6/moving-to-github-and-wicegrid-version-0-4 :


--- RHTML
<%= grid(@tasks_grid) do |g|
   ...
end -%>

<% selected = @tasks_grid.selected_records %>
<p><%= selected.size %> records selected: <%= selected.map(&:id).to_sentence %></p>
---

"See an online example":http://grid.leikind.org/integration_with_application_view

h4. placement of filter related icons

A change in placement of filter related icons (filter icon, reset icon, show/hide icon): if the last column doesn't have  any filter or a column name, icons will be placed in the header of this column, otherwise it falls back to the usual   behavior when an additional table column is added. To change the behavior back to the old style, set   @Wice::Defaults::REUSE_LAST_COLUMN_FOR_FILTER_ICONS@ to @false@ in the configuration file.

"See an online example":http://grid.leikind.org/custom_filters2


h4. wice_grid_assets generator

Copying asset files (images, css, js, and the configuration file) is now done by a plugin generator, not rake tasks:

---
./script/generate wice_grid_assets
---

h4. blank slate

Blank slate feature: it is now possible to replace the grid with some alternative view if no filters are active  and there are no records to render:

--- RHTML
<%= grid(@grid) do |g|

   g.blank_slate  do
     "There are no records"
   end

   g.column  do |product|
      ...
   end
end  -%>
---

There are also two alternative three ways to do it:

--- Ruby
g.blank_slate "some text to be rendered"
---
and
--- Ruby
g.blank_slate :partial => "partial_name"
---

"See an online example":http://grid.leikind.org/no_records

h4. custom filters with symbols

Improvement to custom filters, namely to
--- Ruby
:custom_filter => :symbol
---
and
--- Ruby
:custom_filter => [:symbol1, :symbol2, :symbol3]
---

Now, if the last method returns an array of 2 elements, the first element becomes  the select option label and the second - the select option value (usually @id@).

Before this change the value returned by the method had been used for both the value and the label of the select option.

"See an online example":http://grid.leikind.org/custom_filters3

h4. custom filters and NULL

Values @null@ and @not null@ in a generated custom filter dropdown are treated specially, as SQL @null@ statement  and not as strings.  Value @null@ is transformed into SQL condition @IS NULL@, and @not null@ into @IS NOT NULL@ .

Thus, if in a filter defined by

--- Ruby
:custom_filter => {'No' => 'null', 'Yes' => 'not null', '1' => 1, '2' => '2', '3' => '3'}
---
values @1@, @2@ and @'No'@ are selected (in a multi-select mode),  this will result in the following SQL:

--- SQL
( table.field IN ( '1', '2' ) OR table.field IS NULL )
---

"See an online example":http://grid.leikind.org/null_values

h4. Wice::Defaults::STRING_MATCHING_OPERATORS

 in addition to the configuration constant @Wice::Defaults::STRING_MATCHING_OPERATOR@   to define the operator for matching strings (@LIKE@ in most cases), hash @Wice::Defaults::STRING_MATCHING_OPERATORS@   was added to specify string matching operators on per-database basis:

--- Ruby
Wice::Defaults::STRING_MATCHING_OPERATORS = {
 'ActiveRecord::ConnectionAdapters::MysqlAdapter' => 'LIKE',
 'ActiveRecord::ConnectionAdapters::PostgreSQLAdapter' => 'ILIKE'
}
---

A use-case for this is a Rails application connecting to two databases, one of which is MySQL, and the other is Postgresql. To use case-insensitive matching in Postgresql 'ILIKE' has to be used, but this operator is unknown to MySQL.

h4. td_html_attrs and table_html_attrs shortcuts

@:td_html_attrs@ in column definitions and @table_html_attrs@ in the table definitions are mostly used to add css classes, so a shorter way has been added to add css classes.

Instead of

--- RHTML
<%= grid(@grid, :table_html_attrs => {:class => 'css_class1'}) do |g|
    g.column(:td_html_attrs => {:class => 'css_class2'}) do
      ...
    end
end -%>
---

It's possible to just use the new @:class@ option:

--- RHTML
<%= grid(@grid, :class => 'css_class1') do |g|
  g.column(:class => 'css_class2') do
  end
end -%>
---

h4. allow_multiple_selection

New options for @column@: @:allow_multiple_selection@, use @:allow_multiple_selection => false@ to disable switching between single and multiple selection modes for custom dropdown boxes.

"See an online example":http://grid.leikind.org/custom_filters4

h4. allow_ordering

New parameter for @column@: @:allow_ordering@. Use @:allow_ordering => false@ to disable the ordering of the column.

"See an online example":http://grid.leikind.org/basics6

h4. allow_showing_all_records

Parameter @:allow_showing_all_records@ moved from @initialize_grid@  to the view helper.

h4. other

* Default styles updated.
* Javascript code cleaned up and refactored.
* Quite some number of bugs fixed

== 0.4

* Detached filters: it has become possible to detach filters and place them anywhere on the page, before or after the grid.
  Read section "Detached Filters" in the README.

*  More control over Submit and Reset buttons.
   Two new view helpers: submit_grid_javascript returns javascript which applies current filters; reset_grid_javascript returns javascript
   which resets the grid, clearing the state of filters. This allows to create your own Submit and Reset buttons anywhere on the page
   with the help of button_to_function:

     <%= button_to_function "Submit", submit_grid_javascript(@grid) %>
     <%= button_to_function "Reset",  reset_grid_javascript(@grid) %>

   To complement this feature there are two new parameters in the +grid+ helper :hide_submit_button and :hide_reset_button which
   hide default buttons in the grid if set to true. Together with detached filter this allows to completely
   get rid of the filter row with filters and icons.

* erb_mode option has been moved to the grid view helper - watch for warnings and remove the parameter from initialize_grid if you have it there.

* helper include_wice_grid_assets will require WiceGrid javascripts and stylesheets on demand, that is, only if at least one initialize_grid
  has been called in the controller. Otherwise the helper returns an empty string. However, you can force the old unconditioned behavior if you
  need by submitting  parameter :load_on_demand set to false:
    <%= include_wice_grid_assets(:load_on_demand => false) %>

* Compatibility with Rails asset caching. Helpers names_of_wice_grid_stylesheets and names_of_wice_grid_javascripts return names of stylesheet and
  javascript files and can be used with stylesheet_link_tag and javascript_include_tag with :cache => true. Using this trick you have to deal with
  the parameters correctly, mind that Prototype has to be loaded before WiceGrid javascripts:

    <%= stylesheet_link_tag *(['core',  'modalbox'] + names_of_wice_grid_stylesheets + [ {:cache => true}]) %>
    <%= javascript_include_tag *([:defaults] + names_of_wice_grid_javascripts + [ 'ui', 'swfobject', {:cache => true}]) %>

*  When a page with a WiceGrid instance is loaded there is check a small chunk of javascript that checks whether Prototype is loaded and whether
   the main WiceGrid javascript files is loaded and is of the correct version. Problems are reported to the user via alert() dialog boxes.
   This check has now been disabled in the production mode.

*  The default field separator in generated CSV (comma) can now be overridden by setting :enable_export_to_csv  to a string instead of +true+.

*  It is possible to add your own handcrafted HTML after and/or before each grid row. This works similar to +row_attributes+,
   by adding blocks after_row and before_row:

   <%= grid(@tasks_grid) do |g|
      g.before_row do |task|
        if task.active?
          "<tr><td colspan=\"10\">Custom line for #{t.name}</td></tr>"  # this would add a row
                                                                        # before every active task row
        else
          nil
        end
      end
      .......
    end %>



*  Bug fixes

*  Refactoring
=============

=== 03/04/2009

Possibility to add custom lines after and/or before a grid row.


=== 16/03/2009

Option to override the default field separator in generated CSV (comma).


=== 13/02/2009

a bug fix for incorrect generation if dom ids for javascript calendar filter. Happened only for columns belonging to joined tables

=== 12/01/2009

WiceGrid 0.3 released

=== 12/01/2009

All records mode

=== 10/12/2008

custom_filter made Rails-compliant, a new flavor -  Array of two-element arrays

=== 4/12/2008
A single helper to include all assets in a page

A javascript error message if Prototype is not loaded

A javascript error message if wice_grid.js is not loaded

Added status info to the pagination line:
       « Previous 1 2 3 Next »          1-20 / 50

=== 3/12/2008
First implementation of saved queries


=== 25/11/2008

Negation for string filters: match records where this fiels DOES NOT include the given fragment.

=== 24/11/2008

The string matching operator for string filters (LIKE) has been moved to wice_grid_config.rb in order to make it easier to substitute it with
something else, for example, ILIKE of Postgresql.


=== 19/11/2008

Experimental feature : :table_alias parameter to allow ordering and filtering for joining associations referring the same table.
(See "Joined associations referring to the same table" in README)

=== 18/11/2008

Refactoring

=== 6/11/2008

Ability to provide a callback to a Proc object or a method, the callback will be called with the objects of the current selection of
objects (throughout all pages). Can be used to use the WiceGrid filters set up by the user for further processing of the user's selection  of
objects.

=== 5/11/2008

Javascript calendars as Date/Datetime filters


=== 4/11/2008

Ability to inject custom sql code into the ORDER BY clause, for example, ORDER BY char_length(table1.foo)

=== 4/11/2008

Creates a new branch for version 2.3



=== 21/10/2008

A bugfix related to custom filters influencing other columns with filters
A more informative error message if the grid can't find the underlying database column for a view column (incorrect :column_name and :model)

=== 8/10/2008

New view helper parameter <tt>:sorting_dependant_row_cycling</tt> - When set to true (by default it is false) the row styles +odd+ and +even+
will be changed only when the content of the cell belonging to the sorted column changes. In other words, rows with identical values in the
ordered column will have the same style (color).

=== 3/10/2008

For simple columns like

  g.column :column_name => 'Username', :attribute_name => 'username'  do |account|
    account.username
  end

the following blockless shortcut can be used:

  g.column :column_name => 'Username', :attribute_name => 'username'

In this case +attribute_name+ will be used as the method name to send to the ActiveRecord instance.

=== revision 27 (30/09/2008)

* CSV export
* Custom filters can switch between a dropdown list and a multiple select list, thus allowing to search for records matching
  more that one value (operator OR)

=== revision 17 (19/08/2008)

* A bug fixed: extra_request_parameters did not propagate to will_paginate page panel. Now it does.

=== revision 13 (6/08/2008)

* File <tt>config.rb</tt> renamed.
* New parameters for +column+ :
  * <tt>:boolean_filter_true_label</tt> - overrides the default value for <tt>BOOLEAN_FILTER_TRUE_LABEL</tt> ('+yes+') in the config.
    Only has effect in a column with a boolean filter.
  * <tt>:boolean_filter_false_label</tt> - overrides the default value for <tt>BOOLEAN_FILTER_FALSE_LABEL</tt> ('+no+') in the config.
    Only has effect in a column with a boolean filter.
  * <tt>:filter_all_label</tt> - overrides the default value for <tt>BOOLEAN_FILTER_FALSE_LABEL</tt> ('<tt>--</tt>') in the config.
    Has effect in a column with a boolean filter _or_ a custom filter.

=== revision 11

* New row_attributes method to dynamically generate HTML attributes for the <tt><tr></tt> tag:

	<%= grid(@portal_applications_grid) do |g|
		g.row_attributes{ |portal_application|
			{:id => "#{@portal_applications_grid.name}_row_#{portal_application.id}"}
		}

		g.column{ |portal_application| ... }
		g.column{ |portal_application| ... }
	end    -%>

* The column block can now optionally return an array of two values, where the first element is the cell
  contents and the second is a hash of HTML attributes to be added for the <td> tag of the current cell.

=== revision 10

* New parameter +grid+ parameter:  <tt>:extra_request_parameters</tt>.
  (Read http://redmine.wice.eu/api/wice_grid/classes/Wice/GridViewHelper.html#M000002)

=== 0
