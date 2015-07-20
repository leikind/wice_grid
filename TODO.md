* [done] Replace all icons by Font Awesome, remove the icons
* [done] Joined tables: Instead of
    model: 'ModelClassName'
  use
    assoc: :comments
* [done] Use ActiveRelation merge instead of manually merging hashes and arrays
* [done] Switching between datepickers should be done via :filter_type, not via :helper_style.
  Get rid of :helper_style and Wice::Defaults::HELPER_STYLE
* [done] Fix datepickers when used with Datetime columns

* Implement paging in the app, get rid of Kaminari
* better tests (https://github.com/leikind/wice_grid_testbed)
* review css class names in the generated markup
* More unified and flexible approach to datepickers
* try to guess :table_alias
* throw away saved queries?