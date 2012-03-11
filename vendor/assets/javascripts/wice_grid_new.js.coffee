showIconId = (gridName) ->
  "#" + gridName + "_show_icon"

hideIconId = (gridName) ->
  "#" + gridName + "_hide_icon"

filterRowId = (gridName) ->
  "#" + gridName + "_filter_row"

jQuery ->

  $('.hide-filter').click ->
    gridName = this.id.replace(/_hide_icon$/, '')
    $(this).hide()
    $(showIconId(gridName)).show()
    $(filterRowId(gridName)).hide()
    false


  $('.show-filter').click ->
    gridName = this.id.replace(/_show_icon$/, '')
    $(this).hide()
    $(hideIconId(gridName)).show()
    $(filterRowId(gridName)).show()
    false

