hideFilter = '.wg-hide-filter'
showFilter = '.wg-show-filter'
filterRow = '.wg-filter-row'

setupHidingShowingOfFilterRow = (wiceGridContainer) ->
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

setupShowingAllRecords = (wiceGridContainer, gridProcessor) ->
  $('.wg-show-all-link, .wg-back-to-pagination-link', wiceGridContainer).click (event) ->
    event.preventDefault()
    gridState = $(this).data("grid-state")
    confirmationMessage = $(this).data("confim-message")
    reloadGrid = ->
      gridProcessor.reload_page_for_given_grid_state gridState
    if confirmationMessage
      if confirm(confirmationMessage)
        reloadGrid()
    else
      reloadGrid()



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

  $('.wg-external-submit-button').click (event) ->
    event.preventDefault()
    if gridName = $(this).data('grid-name')
      gridProcessor.process()
    false

  $('.wg-external-reset-button').click (event) ->
    event.preventDefault()
    if gridName = $(this).data('grid-name')
      gridProcessor.reset()
    false

  $('.wg-detached-filter').each (index, detachedFilterContainer) ->
    if gridName = $(this).data('grid-name')
      $('input[type=text]', this).keydown (event) ->
        if event.keyCode == 13
          event.preventDefault()
          gridProcessor.process()
          false



jQuery ->

  $(".wice-grid-container").each (index, wiceGridContainer) ->

    gridName = wiceGridContainer.id

    dataDiv = $(".wg-data", wiceGridContainer)

    processorInitializerArguments = dataDiv.data("processor-initializer-arguments")

    filterDeclarations = dataDiv.data("filter-declarations")

    console.log gridName
    console.log filterDeclarations
    grid = new WiceGridProcessor(gridName,
      processorInitializerArguments[0], processorInitializerArguments[1],
      processorInitializerArguments[2], processorInitializerArguments[3],
      processorInitializerArguments[4], processorInitializerArguments[5])

    for filterDeclaration in filterDeclarations
      do (filterDeclaration) ->

        grid.register
          filter_name : filterDeclaration.filter_name
          detached    : filterDeclaration.detached
          templates   : filterDeclaration.declaration.templates
          ids         : filterDeclaration.declaration.ids

    setupHidingShowingOfFilterRow wiceGridContainer
    setupSubmitReset wiceGridContainer, grid
    setupShowingAllRecords wiceGridContainer, grid

    window[gridName] = grid
