

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

setupShowingAllRecords = (wiceGridContainer) ->
  $('.wg-show-all-link, .wg-back-to-pagination-link', wiceGridContainer).click (event) ->
    event.preventDefault()
    gridState = $(this).data("grid-state")
    confirmationMessage = $(this).data("confim-message")
    reloadGrid = ->
      window[wiceGridContainer.id].reload_page_for_given_grid_state gridState
    if confirmationMessage && confirm(confirmationMessage)
      reloadGrid()
    else
      reloadGrid()



setupSubmitReset = (wiceGridContainer) ->
  $('.submit', wiceGridContainer).click ->
    window[wiceGridContainer.id].process()
    false

  $('.reset', wiceGridContainer).click ->
    window[wiceGridContainer.id].reset()
    false

  $('.wg-filter-row input[type=text]', wiceGridContainer).keydown (event) ->
    if event.keyCode == 13
      event.preventDefault()
      window[wiceGridContainer.id].process()
      false

  $('.wg-external-submit-button').click (event) ->
    event.preventDefault()
    if gridName = $(this).data('grid-name')
      window[gridName].process()
    false

  $('.wg-external-reset-button').click (event) ->
    event.preventDefault()
    if gridName = $(this).data('grid-name')
      window[gridName].reset()
    false

  $('.wg-detached-filter').each (index, detachedFilterContainer) ->
    if gridName = $(this).data('grid-name')
      $('input[type=text]', this).keydown (event) ->
        if event.keyCode == 13
          event.preventDefault()
          window[gridName].process()
          false








setupBehaviorForGrid = (wiceGridContainer) ->

  setupHidingShowingOfFilterRow(wiceGridContainer)
  setupSubmitReset(wiceGridContainer)
  setupShowingAllRecords(wiceGridContainer)



jQuery ->

  $(".wice-grid-container").each (index, wiceGridContainer) ->
    setupBehaviorForGrid(wiceGridContainer)


