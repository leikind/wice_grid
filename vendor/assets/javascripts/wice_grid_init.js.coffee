$(document).on 'turbolinks:load', -> initWiceGrid()

globalVarForAllGrids = 'wiceGrids'

initWiceGrid = ->

  $(".wice-grid-container").each (index, wiceGridContainer) ->

    gridName = wiceGridContainer.id
    dataDiv = $(".wg-data", wiceGridContainer)

    processorInitializerArguments = dataDiv.data("processor-initializer-arguments")

    filterDeclarations = dataDiv.data("filter-declarations")

    focusElementIfNeeded dataDiv.data("foc")

    gridProcessor = new WiceGridProcessor(gridName,
      processorInitializerArguments[0], processorInitializerArguments[1],
      processorInitializerArguments[2], processorInitializerArguments[3],
      processorInitializerArguments[4], processorInitializerArguments[5])

    for filterDeclaration in filterDeclarations
      do (filterDeclaration) ->
        if filterDeclaration?
          gridProcessor.register
            filterName : filterDeclaration.filterName
            detached    : filterDeclaration.detached
            templates   : filterDeclaration.declaration.templates
            ids         : filterDeclaration.declaration.ids

    unless window[globalVarForAllGrids]
      window[globalVarForAllGrids] = {}

    window[globalVarForAllGrids][gridName] = gridProcessor

    # setting up stuff for in the context of each grid
    setupSubmitReset                   wiceGridContainer, gridProcessor
    setupCsvExport                     wiceGridContainer, gridProcessor
    setupHidingShowingOfFilterRow      wiceGridContainer
    setupShowingAllRecords             wiceGridContainer, gridProcessor
    setupMultiSelectToggle             wiceGridContainer
    setupAutoreloadsForInternalFilters wiceGridContainer, gridProcessor
    setupBulkToggleForActionColumn     wiceGridContainer

  setupAutoreloadsForExternalFilters()
  setupExternalSubmitReset()
  setupExternalCsvExport()
  setupDatepicker()

  # for all grids on oage because it does not matter which grid it is
  setupMultiSelectToggle $('.wg-detached-filter')



moveDateBoundIfInvalidPeriod = (dataFieldNameWithTheOtherDatepicker, datepickerHiddenField, selectedDate, dateFormat, predicate) ->
  if (datepickerId = datepickerHiddenField.data(dataFieldNameWithTheOtherDatepicker)) &&
    (theOtherDatepicker = $(_datepickerId = "#" + datepickerId)) &&
    (theOtherDate = theOtherDatepicker.datepicker('getDate')) &&

    predicate(theOtherDate, selectedDate)
      theOtherDatepicker.datepicker("setDate", selectedDate)
      theOtherDatepicker.next().next().html  $.datepicker.formatDate(dateFormat, selectedDate)


setupDatepicker = ->
  if $('.date-filter.wg-jquery-datepicker').length != 0
    setupJqueryUiDatepicker()

  if $('.date-filter.wg-bootstrap-datepicker').length != 0
    setupBootstrapDatepicker()


setupBootstrapDatepicker = ->
  # check for bootstrap datepicker
  unless $.fn.datepicker
    alert """Seems like you do not have Bootstrap datepicker gem (https://github.com/Nerian/bootstrap-datepicker-rails)
      installed. Either install it pick another filter with :filter_type.
    """
    return

  $('.date-filter.wg-bootstrap-datepicker input:text[data-provide=datepicker]').each (index, dateField) ->

    $(dateField).datepicker().on 'hide', (event) ->
      $self = $(event.currentTarget)

      eventToTriggerOnChange = $self.data('close-calendar-event-name')

      if eventToTriggerOnChange
        $self.trigger(eventToTriggerOnChange)

      else if $self.attr('id').split('_').pop() == 'fr'
        $to = $self.parent().next().find('input:text.check-for-bsdatepicker')
        if $to.length > 0
          $to.datepicker 'show'


setupJqueryUiDatepicker = ->
  # check jquery ui datepickeer
  unless $.datepicker
    alert """Seems like you do not have jQuery datepicker (http://jqueryui.com/demos/datepicker/)
        installed. Either install it pick another filter with :filter_type.
      """
  # setting up the locale for datepicker
  if locale = $('.date-filter.wg-jquery-datepicker input[type=hidden]').data('locale')
    $.datepicker.setDefaults($.datepicker.regional[locale]);


  $('.date-filter.wg-jquery-datepicker .date-label').each  (index, removeLink) ->
    datepickerHiddenField  = $('#' + $(removeLink).data('dom-id'))

    eventToTriggerOnChange = datepickerHiddenField.data('close-calendar-event-name')

    # setting up the remove link for datepicker
    $(removeLink).click (event) ->
      $(this).html('')
      datepickerHiddenField.val('')
      if eventToTriggerOnChange
        datepickerHiddenField.trigger(eventToTriggerOnChange)
      event.preventDefault()
      false
    that = this

    dateFormat = datepickerHiddenField.data('date-format')

    yearRange = datepickerHiddenField.data('date-year-range')

    labelText = datepickerHiddenField.data('button-text')

    # datepicker constructor
    datepickerHiddenField.datepicker
      firstDay:        1
      dateFormat:      dateFormat
      changeMonth:     true
      changeYear:      true
      yearRange:       yearRange

      onSelect: (dateText, inst) ->

        selectedDate = $(this).datepicker("getDate")

        moveDateBoundIfInvalidPeriod(
          'the-other-datepicker-id-to',
          datepickerHiddenField,
          selectedDate,
          dateFormat,
          (theOther, selected)-> theOther < selected
        )

        moveDateBoundIfInvalidPeriod(
          'the-other-datepicker-id-from',
          datepickerHiddenField,
          selectedDate,
          dateFormat,
          (theOther, selected)-> theOther > selected
        )

        $(that).html(dateText)
        if eventToTriggerOnChange
          datepickerHiddenField.trigger(eventToTriggerOnChange)

    datepickerContainer = datepickerHiddenField.parent()

    $(removeLink).before(" <i class=\"fa fa-calendar ui-datepicker-trigger\" title=\"#{labelText}\" ></i> ")

    newlyAdded = $('.fa-calendar', datepickerContainer)

    newlyAdded.click ->

      datepickerHiddenField.datepicker("show")


# hiding and showing the row with filters
setupHidingShowingOfFilterRow = (wiceGridContainer) ->
  hideFilter = '.wg-hide-filter'
  showFilter = '.wg-show-filter'
  filterRow = '.wg-filter-row'

  $(hideFilter, wiceGridContainer).click ->
    $(this).hide()
    $(showFilter, wiceGridContainer).show()
    $(filterRow, wiceGridContainer).hide()

  $(showFilter, wiceGridContainer).click ->
    $(this).hide()
    $(hideFilter, wiceGridContainer).show()
    $(filterRow, wiceGridContainer).show()


setupCsvExport = (wiceGridContainer, gridProcessor) ->
  $('.export-to-csv-button', wiceGridContainer).click ->
    gridProcessor.exportToCsv()


# trigger submit/reset from within the grid
setupSubmitReset = (wiceGridContainer, gridProcessor) ->
  $('.submit', wiceGridContainer).click ->
    gridProcessor.process()

  $('.reset', wiceGridContainer).click ->
    gridProcessor.reset()

  $('.wg-filter-row input[type=text], .wg-filter-row input:text[data-provide=datepicker]', wiceGridContainer).keydown (event) ->
    if event.keyCode == 13
      event.preventDefault()
      gridProcessor.process()

SetEnd = (txt) ->
  if txt.createTextRange
    #IE
    FieldRange = txt.createTextRange()
    FieldRange.moveStart 'character', txt.value.length
    FieldRange.collapse()
    FieldRange.select()
  else
    #Firefox and Opera
    txt.focus()
    length = txt.value.length
    txt.setSelectionRange length, length
  return

focusElementIfNeeded = (focusId) ->
  elements = $('#' + focusId)
  if elToFocus = elements[0]
    SetEnd elToFocus

# autoreload for internal filters
setupAutoreloadsForInternalFilters = (wiceGridContainer, gridProcessor) ->
  $('select.auto-reload, input.native-datepicker.auto-reload', wiceGridContainer).change ->
    gridProcessor.process()

  $('input.auto-reload', wiceGridContainer).keyup (event)->
    if isKeySignificant event.which
      gridProcessor.setProcessTimer(this.id)

  $('input.negation-checkbox.auto-reload', wiceGridContainer).click ->
    gridProcessor.process()

  $(document).bind 'wg:calendarChanged_' + gridProcessor.name, ->
    gridProcessor.process()



isKeySignificant = (keyCode, func)->
  [37, 38, 39, 40, 9, 27].indexOf(keyCode) == -1

# autoreload for internal filters
setupAutoreloadsForExternalFilters =  ->

  $('.wg-detached-filter').each (index, detachedFilterContainer) ->
    gridProcessor = getGridProcessorForElement(detachedFilterContainer)
    if gridProcessor
      $('select.auto-reload, input.native-datepicker.auto-reload', detachedFilterContainer).change ->
        gridProcessor.process()

      $('input.auto-reload', detachedFilterContainer).keyup (event)->
        if isKeySignificant event.which
          gridProcessor.setProcessTimer(this.id)

      $('input.negation-checkbox.auto-reload', detachedFilterContainer).click ->
        gridProcessor.process()


# trigger the all records mode
setupShowingAllRecords = (wiceGridContainer, gridProcessor) ->
  $('.wg-show-all-link, .wg-back-to-pagination-link', wiceGridContainer).click (event) ->
    event.preventDefault()
    gridState = $(this).data("grid-state")
    confirmationMessage = $(this).data("confim-message")
    reloadGrid = ->
      gridProcessor.reloadPageForGivenGridState gridState
    if confirmationMessage
      if confirm(confirmationMessage)
        reloadGrid()
    else
      reloadGrid()

# dropdown filter multiselect
setupMultiSelectToggle = (wiceGridContainer)->
  $('.expand-multi-select-icon', wiceGridContainer).click ->
    $(this).prev().each (index, select) ->
      select.multiple = true
    $(this).next().show()
    $(this).hide()

  $('.collapse-multi-select-icon', wiceGridContainer).click ->
    $(this).prev().prev().each (index, select) ->
      select.multiple = false
    $(this).prev().show()
    $(this).hide()


setupBulkToggleForActionColumn = (wiceGridContainer) ->
  $('.select-all', wiceGridContainer).click ->
    $('.sel input', wiceGridContainer).prop('checked', true).trigger('change')

  $('.deselect-all', wiceGridContainer).click ->
    $('.sel input', wiceGridContainer).prop('checked', false).trigger('change')

  $('.wg-select-all', wiceGridContainer).click ->
    $('.sel input', wiceGridContainer).prop('checked', $(this).prop('checked')).trigger('change')


getGridProcessorForElement = (element) ->
  gridName = $(element).data('grid-name')
  if gridName && window[globalVarForAllGrids]
    window[globalVarForAllGrids][gridName]
  else
    null


setupExternalCsvExport =  ->

  $(".wg-external-csv-export-button").each (index, externalCsvExportButton) ->
    gridProcessor = getGridProcessorForElement(externalCsvExportButton)
    if gridProcessor
      $(externalCsvExportButton).click (event) ->
        gridProcessor.exportToCsv()


setupExternalSubmitReset =  ->

  $(".wg-external-submit-button").each (index, externalSubmitButton) ->
    gridProcessor = getGridProcessorForElement(externalSubmitButton)
    if gridProcessor
      $(externalSubmitButton).click (event) ->
        gridProcessor.process()
        event.preventDefault()
        false

  $(".wg-external-reset-button").each (index, externalResetButton) ->
    gridProcessor = getGridProcessorForElement(externalResetButton)
    if gridProcessor
      $(externalResetButton).click (event) ->
        gridProcessor.reset()
        event.preventDefault()
        false


  $('.wg-detached-filter').each (index, detachedFilterContainer) ->
    gridProcessor = getGridProcessorForElement(detachedFilterContainer)
    if gridProcessor
      $('input[type=text], input:text[data-provide=datepicker]', this).keydown (event) ->
        if event.keyCode == 13
          gridProcessor.process()
          event.preventDefault()
          false

window['getGridProcessorForElement'] = getGridProcessorForElement
window['initWiceGrid'] = initWiceGrid
