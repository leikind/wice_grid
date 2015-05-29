class WiceGridProcessor
  constructor: (@name, @baseRequestForFilter, @baseLinkForShowAllRecords, @linkForExport, @parameterNameForQueryLoading, @parameterNameForFocus, @environment) ->
    @filterDeclarations = new Array();
    @checkIfJsFrameworkIsLoaded()

  checkIfJsFrameworkIsLoaded :  ->
    if ! jQuery
      alert "jQuery not loaded, WiceGrid cannot proceed!"

  toString :  ->
    "<WiceGridProcessor instance for grid '" + @name + "'>"


  process : (domIdToFocus)->
    @visit @buildUrlWithParams(domIdToFocus)

  visit : (path) ->
    if Turbolinks?
      Turbolinks.visit path
    else
      window.location = path

  setProcessTimer : (domIdToFocus)->

    if @timer
      clearTimeout(@timer)
      @timer = null

    processor = this

    @timer = setTimeout(
      -> processor.process(domIdToFocus)
      1000
    )

  reloadPageForGivenGridState : (gridState)->
    requestPath = @gridStateToRequest(gridState)
    @visit @appendToUrl(@baseLinkForShowAllRecords, requestPath)


  gridStateToRequest : (gridState)->
    jQuery.map(
      gridState
      (pair) -> encodeURIComponent(pair[0]) + '=' + encodeURIComponent(pair[1])
    ).join('&')


  appendToUrl : (url, str)->

    sep = if url.indexOf('?') != -1
      if /[&\?]$/.exec(url)
        ''
      else
        '&'
    else
      '?'
    url + sep + str

  buildUrlWithParams : (domIdToFocus)->
    results = new Array()
    jQuery.each(
      @filterDeclarations
      (i, filterDeclaration)=>
        param = @readValuesAndFormQueryString(filterDeclaration.filterName, filterDeclaration.detached, filterDeclaration.templates, filterDeclaration.ids)

        if param && param != ''
          results.push(param)
    )

    res = @baseRequestForFilter
    if  results.length != 0
      allFilterParams = results.join('&')
      res = @appendToUrl(res, allFilterParams)

    if domIdToFocus
      res = @appendToUrl(res, @parameterNameForFocus + domIdToFocus)

    res



  reset : ->
    @visit @baseRequestForFilter


  exportToCsv : ->
    @visit @linkForExport


  register : (func)->
    @filterDeclarations.push(func)


  readValuesAndFormQueryString : (filterName, detached, templates, ids)->
    res = new Array()

    for i in [0 .. templates.length-1]

      if $(ids[i]) == null
        if this.environment == "development"
          message = 'WiceGrid: Error reading state of filter "' + filterName + '". No DOM element with id "' + ids[i] + '" found.'
          if detached
            message += 'You have declared "' + filterName + '" as a detached filter but have not output it anywhere in the template. Read documentation about detached filters.'

          alert(message);

        return ''

      el = $('#' + ids[i])

      if el[0] && el[0].type == 'checkbox'
        if el[0].checked
          val = 1;
      else
        val = el.val()

      if val instanceof Array
        for j in [0 .. val.length-1]
          if val[j] && val[j] != ""
            res.push(templates[i] + encodeURIComponent(val[j]))

      else if val &&  val != ''
        res.push(templates[i]  + encodeURIComponent(val));


    res.join('&');

  this


WiceGridProcessor._version = '3.4'

window['WiceGridProcessor'] = WiceGridProcessor
