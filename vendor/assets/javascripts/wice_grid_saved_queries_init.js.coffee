$(document).on 'page:load ready', -> savedQueriesInit()


savedQueriesInit = ->

  $('.wice-grid-save-query-field').keydown (event) ->
    if event.keyCode == 13
      saveQuery($(this).next(), event)

  $(".wice-grid-save-query-button").click (event) ->
    saveQuery(this, event)

  $(".wice-grid-delete-query").click (event) ->
    deleteQuery(this, event)

  $(".wice-grid-query-load-link").click (event) ->
    loadQuery(this, event)

loadQuery = (loadLink, event) ->
  if gridProcessor = window.getGridProcessorForElement(loadLink)
    queryId = $(loadLink).data('query-id')

    request = gridProcessor.appendToUrl(
      gridProcessor.buildUrlWithParams(),
      gridProcessor.parameterNameForQueryLoading +  encodeURIComponent(queryId)
    )

    gridProcessor.visit request

  event.preventDefault()
  event.stopPropagation()
  false


deleteQuery = (deleteQueryButton, event) ->

  confirmation = $(deleteQueryButton).data('wg-confirm')

  invokeConfirmation = if confirmation
    -> confirm(confirmation)
  else
    -> true

  if invokeConfirmation() && (gridProcessor = window.getGridProcessorForElement(deleteQueryButton))

    jQuery.ajax
      url: $(deleteQueryButton).attr('href')
      async: true
      dataType: 'json'
      success:  (data, textStatus, jqXHR) ->
        onChangeToQueryList(data, gridProcessor.name)
      type: 'POST'
  event.preventDefault()
  event.stopPropagation()
  false

saveQuery = (saveQueryButton, event) ->
  if gridProcessor = window.getGridProcessorForElement(saveQueryButton)
    _saveQueryButton = $(saveQueryButton)
    basePathToQueryController = _saveQueryButton.data('base-path-to-query-controller')
    gridState                 = _saveQueryButton.data('parameters')
    inputIds                  = _saveQueryButton.data('ids')
    inputField                = _saveQueryButton.prev()

    if inputIds instanceof Array
      inputIds.each (domId) ->
        gridState.push(['extra[' + domId + ']', $('#'+ domId).val()])

    queryName = inputField.val()

    requestPath = gridProcessor.gridStateToRequest(gridState)

    jQuery.ajax
      url: basePathToQueryController
      async: true
      data: requestPath + '&query_name=' + encodeURIComponent(queryName)
      dataType: 'json'
      success:  (data, textStatus, jqXHR) ->
        onChangeToQueryList(data, gridProcessor.name, queryName, inputField)
      type: 'POST'

    event.preventDefault()
    false

onChangeToQueryList = (data, gridName, queryName, inputField) ->
  notificationMessagesDomId = "##{gridName}_notification_messages"
  gridTitleId  = "##{gridName}_title"
  queryListId  = "##{gridName}_query_list"
  inputField.val('') if queryName
  if errorMessages = data['error_messages']
    $(notificationMessagesDomId).text(errorMessages)
  else
    if notificationMessages = data['notification_messages']
      $(notificationMessagesDomId).text(notificationMessages)
    $(gridTitleId).html("<h3>#{queryName}</h3>") if queryName
    $(queryListId).replaceWith(data['query_list'])
    $(queryListId).effect('highlight') if jQuery.ui

    $(".wice-grid-delete-query", $(queryListId)).click (event) ->
      deleteQuery(this, event)

    $(".wice-grid-query-load-link", $(queryListId)).click (event) ->
      loadQuery(this, event)
