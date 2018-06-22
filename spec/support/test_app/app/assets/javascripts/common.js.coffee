init = ->
  $("select.reload-on-change").change ->
    this.form.submit()

$(document).on 'page:load ready', init
$(document).on 'turbolinks:render', init
