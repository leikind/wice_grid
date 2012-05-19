jQuery ->
  initWiceGrid()

initWiceGrid = ->


  $(".wice-grid-container").each (index, wiceGridContainer) ->

    gridName = wiceGridContainer.id
    dataDiv = $(".wg-data", wiceGridContainer)

    processorInitializerArguments = dataDiv.data("processor-initializer-arguments")

    filterDeclarations = dataDiv.data("filter-declarations")

    gridProcessor = new WiceGridProcessor(gridName,
      processorInitializerArguments[0], processorInitializerArguments[1],
      processorInitializerArguments[2], processorInitializerArguments[3],
      processorInitializerArguments[4], processorInitializerArguments[5])

    for filterDeclaration in filterDeclarations
      do (filterDeclaration) ->
        gridProcessor.register
          filterName : filterDeclaration.filterName
          detached    : filterDeclaration.detached
          templates   : filterDeclaration.declaration.templates
          ids         : filterDeclaration.declaration.ids

    window[gridName] = gridProcessor

    setupDatepicker()
    setupSubmitReset wiceGridContainer, gridProcessor
    setupHidingShowingOfFilterRow wiceGridContainer
    setupShowingAllRecords wiceGridContainer, gridProcessor
    setupMultiSelectToggle wiceGridContainer

  setupExternalSubmitReset()




# datepicker logic
setupDatepicker = ->
  # check if datepicker is loaded
  if $('.wice-grid-container input.check-for-datepicker[type=hidden], .wg-detached-filter input.check-for-datepicker[type=hidden]').length != 0
    unless $.datepicker
      alert """Seems like you do not have jQuery datepicker (http://jqueryui.com/demos/datepicker/)
        installed. Either install it or set Wice::Defaults::HELPER_STYLE to :standard in
        wice_grid_config.rb in order to use standard Rails date helpers
      """

  # setting up the locale for datepicker
  if locale = $('.wice-grid-container input[type=hidden], .wg-detached-filter input[type=hidden]').data('locale')
    $.datepicker.setDefaults($.datepicker.regional[locale]);


  $('.wice-grid-container .date-label, .wg-detached-filter .date-label').each  (index, removeLink) ->
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

    # datepicker constructor
    datepickerHiddenField.datepicker
      firstDay:        1
      showOn:          "button"
      dateFormat:      datepickerHiddenField.data('date-format')
      buttonImage:     datepickerHiddenField.data('button-image')
      buttonImageOnly: true
      buttonText:      datepickerHiddenField.data('button-text')
      changeMonth:     true
      changeYear:      true
      onSelect: (dateText, inst) ->
        $(that).html(dateText)
        if eventToTriggerOnChange
          datepickerHiddenField.trigger(eventToTriggerOnChange)

# hiding and showing the row with filters
setupHidingShowingOfFilterRow = (wiceGridContainer) ->
  hideFilter = '.wg-hide-filter'
  showFilter = '.wg-show-filter'
  filterRow = '.wg-filter-row'

  $(hideFilter, wiceGridContainer).click ->
    $(this).hide()
    $(showFilter, wiceGridContainer).show()
    $(filterRow, wiceGridContainer).hide()
    false

  $(showFilter, wiceGridContainer).click ->
    $(this).hide()
    $(hideFilter, wiceGridContainer).show()
    $(filterRow, wiceGridContainer).show()
    false


# trigger submit/reset from within the grid
setupSubmitReset = (wiceGridContainer, gridProcessor) ->
  $('.submit', wiceGridContainer).click ->
    gridProcessor.process()
    false

  $('.reset', wiceGridContainer).click ->
    gridProcessor.reset()
    false

  $('.wg-filter-row input[type=text]', wiceGridContainer).keydown (event) ->
    if event.keyCode == 13
      event.preventDefault()
      gridProcessor.process()
      false


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


getGridProcessorForElement = (element) ->
  gridName = $(element).data('grid-name')
  if gridName
    window[gridName]
  else
    null


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
      $('input[type=text]', this).keydown (event) ->
        if event.keyCode == 13
          gridProcessor.process()
          event.preventDefault()
          false
