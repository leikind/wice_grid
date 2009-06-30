module Wice

  module Defaults

    # Style of the view helper.
    # +false+ is a usual view helper.
    # +true+ will allow to embed erb content in column (cell) definitions.
    ERB_MODE = false


    # Default number of rows to show per page.
    PER_PAGE = 10

    # Default order direction
    ORDER_DIRECTION = 'asc'

    # Default name for a grid. A grid name is the basis for a lot of
    # names including parameter names, DOM IDs, etc
    # The shorter the name is the shorter the request URI will be.
    GRID_NAME = 'grid'


    SHOW_HIDE_FILTER_ICON = 'icons/grid/page_white_find.png'

    SHOW_FILTER_TOOLTIP = 'Show filter'
    HIDE_FILTER_TOOLTIP = 'Hide filter'
    CSV_EXPORT_TOOLTIP  = 'Export to CSV'

    # Icon to trigger filtering.
    FILTER_ICON = 'icons/grid/table_refresh.png'

    # Icon to reset the filter.
    RESET_ICON = "icons/grid/table.png"

    # Icon to reset the filter.
    TOGGLE_MULTI_SELECT_ICON = "/images/icons/grid/expand.png"

    # CSV Export icon.
    CSV_EXPORT_ICON = "/images/icons/grid/page_white_excel.png"


    FILTER_TOOLTIP = "Filter"
    RESET_FILTER_TOOLTIP = "Reset"

    # The label of the first option of a custom dropdown list meaning 'All items'
    CUSTOM_FILTER_ALL_LABEL = '--'

    BOOLEAN_FILTER_TRUE_LABEL  = 'yes'
    BOOLEAN_FILTER_FALSE_LABEL = 'no'



    # Show the upper pagination panel by default or not
    SHOW_UPPER_PAGINATION_PANEL = false


    # Enabling CSV export by default
    ENABLE_EXPORT_TO_CSV = false


    # The strategy when to show the filter.
    # * <tt>:when_filtered</tt> - when the table is the result of filtering
    # * <tt>:always</tt>        - show the filter always
    # * <tt>:no</tt>            - never show the filter
    SHOW_FILTER = :when_filtered
    
    # SQL operator used for matching strings in string filters.
    STRING_MATCHING_OPERATOR = 'LIKE'
    # STRING_MATCHING_OPERATOR = 'ILIKE' # Use this for Postgresql case-insensitive matching.

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    #                                will_paginate                              #

    PREVIOUS_LABEL = '« Previous'
    NEXT_LABEL     = 'Next »'

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    #                              Advanced Filters                             #

    # The title of the checkox to turn on negation
    NEGATION_IN_STRING_FILTERS = true

    # The title of the checkox to turn on negation
    NEGATION_CHECKBOX_TITLE = 'Exclude'


    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    #                              Showing All Queries                          #
    
    # Enable or disable showing all queries (non-paginated table)
    ALLOW_SHOWING_ALL_QUERIES = true
    
    # If number of all queries is more than this value, the user will be given a warning message
    START_SHOWING_WARNING_FROM = 100
    
    # link to switch to "ahow all records"
    SHOW_ALL_RECORDS_LABEL = 'show all'

    # tooltip for the link to switch to "ahow all records"
    SHOW_ALL_RECORDS_TOOLTIP = 'Show all records'
    
    # Warning message shown when the user wants to switch to all-records mode
    ALL_QUERIES_WARNING = 'Are you sure you want to display all records?'

    # link to paginated view
    SWITCH_BACK_TO_PAGINATED_MODE_LABEL = "back to paginated view"
    
    # tooltip for the link to paginated view
    SWITCH_BACK_TO_PAGINATED_MODE_TOOLTIP = "Switch back to the view with pages"

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    #                               Saving Queries                              #
    
    # Icon to delete a saved query
    DELETE_QUERY_ICON = 'icons/grid/delete.png'    
    
    # ActiveRecord model to store queries. Read the documentation for details
    # QUERY_STORE_MODEL = 'WiceGridSerializedQuery'
    QUERY_STORE_MODEL = 'SavedQuery'
    
    SAVED_QUERY_PANEL_TITLE = 'Saved Queries'
    SAVE_QUERY_BUTTON_LABEL = 'Save the state of filters'
    
    SAVED_QUERY_DELETION_CONFIRMATION = 'Are you sure?'
    SAVED_QUERY_DELETION_LINK_TITLE   = 'Delete query'
    SAVED_QUERY_LINK_TITLE            = 'Load query'
    
    VALIDATES_UNIQUENESS_ERROR = "A query with this name already exists"
    VALIDATES_PRESENCE_ERROR   = "Please sumbit the name of the custom query"

    QUERY_DELETED_MESSAGE = "Saved query deleted."
    QUERY_SAVED_MESSAGE   = "Query saved."

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    #            Here go settings related to the calendar helpers               #

    # The default style of the date and datetime helper
    # * <tt>:calendar</tt> - JS calendar
    # * <tt>:standard</tt> - standard Rails date and datetime helpers
    HELPER_STYLE = :calendar

    # Path to the directory with dynarch calendar files.
    DYNARCH_CALENDAR_ASSETS_PATH = '/javascripts/grid_calendar'

    # Format of the datetime displayed.
    # If you change the format, make sure to check if +DATETIME_PARSER+ can still parse this string.
    DATETIME_FORMAT = "%Y-%m-%d %H:%M"

    # Format of the date displayed.
    # If you change the format, make sure to check if +DATE_PARSER+ can still parse this string.
    DATE_FORMAT     =  "%Y-%m-%d"

    # With Calendar helpers enabled the parameter sent is the string displayed. This lambda will be given a date string in the
    # format defined by +DATETIME_FORMAT+ and must generate a DateTime object.
    # In many cases <tt>DateTime.parse</tt> is enough, for instance,  <tt>%Y-%m-%d</tt>. If you change the format, make sure to check this code
    # and modify it if needed.
    DATETIME_PARSER = lambda{|datetime_string| DateTime.parse(datetime_string) }

    # With Calendar helpers enabled the parameter sent is the string displayed. This lambda will be given a date string in the
    # format defined by +DATETIME+ and must generate a Date object.
    # In many cases <tt>Date.parse</tt> is enough, for instance,  <tt>%Y-%m-%d</tt>. If you change the format, make sure to check this code
    # and modify it if needed.
    DATE_PARSER = lambda{|datetime_string| Date.parse(datetime_string) }

    # Icon to popup the calendar.
    CALENDAR_ICON = "/images/icons/grid/calendar_view_month.png"

    # Title of the icon clicking on which will show the calendar to set the FROM date.
    DATE_SELECTOR_TOOLTIP_FROM = 'From'
    # Title of the icon clicking on which will show the calendar to set the TO date.
    DATE_SELECTOR_TOOLTIP_TO = 'To'

    # Title of the date string.
    DATE_STRING_TOOLTIP = 'Click to delete'

    # Style of the calendar
    # possible styles:
    # * green
    # * blue
    # * blue2
    # * brown
    # * system
    # * tas
    # * win2k-1
    # * win2k-2
    # * win2k-cold-1
    # * win2k-cold-2
    DYNARCH_CALENDAR_STYLE = 'green'

    # Language of the calendar.
    # Look for possible values in <tt>/vendor/plugins/wice_grid/javascripts/grid_calendar/lang</tt>, the part of the file name between
    # <tt>calendar-</tt> and <tt>.js</tt> is the codename for the language.
    DYNARCH_CALENDAR_LANG = 'en'
  end
end