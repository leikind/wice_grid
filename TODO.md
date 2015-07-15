* Replace all icons by Font Awesome, remove the icons
* Switching between datepickers should be done via :filter_type, not via :helper_style.
  Get rid of :helper_style and Wice::Defaults::HELPER_STYLE
* More unified and flexible approach to datepickers
* Fix datepickers when used with Datetime columns
* Implement paging in the app, get rid of Kaminari
* Joined tables: Instead of
    model: 'ModelClassName'
  use
    association: :comments
* better tests (https://github.com/leikind/wice_grid_testbed)
* review css class names in the generated markup
* throw away saved queries?
