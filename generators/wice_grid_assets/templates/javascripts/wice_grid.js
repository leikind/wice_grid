WiceGridProcessor = Class.create( {
  
  initialize : function(name, base_request_for_filter, base_link_for_show_all_records, 
                        link_for_export, parameter_name_for_query_loading, environment){
    this.checkIfPrototypeIsLoaded();
    this.name = name;
    this.parameter_name_for_query_loading = parameter_name_for_query_loading;
    this.base_request_for_filter = base_request_for_filter;
    this.base_link_for_show_all_records = base_link_for_show_all_records;
    this.link_for_export = link_for_export;
    this.filter_declarations = new Array();
    this.environment = environment;
  },
  
  toString : function(){
    return "<WiceGridProcessor instance for grid '" + this.name + "'>";
  },

  checkIfPrototypeIsLoaded : function(){
    if (typeof(Prototype) == "undefined"){
      alert("Prototype javascript library not loaded, WiceGrid cannot proceed!")
    }
  },

  process : function(){
    window.location = this.build_url_with_params();
  },

  reload_page_for_given_grid_state : function(grid_state){
    request_path = this.grid_state_to_request(grid_state);
    window.location = this.append_to_url(this.base_link_for_show_all_records, request_path);
  },

  load_query :function(query_id){
    request = this.append_to_url(this.build_url_with_params(),
      (this.parameter_name_for_query_loading +  encodeURIComponent(query_id)));
    window.location = request;
  },

  save_query : function(query_name, base_path_to_query_controller, grid_state, input_ids){
    if (input_ids instanceof Array) {
      input_ids.each(function(dom_id){
        grid_state.push(['extra[' + dom_id + ']', $F(dom_id)])
      });
    }
    
    request_path = this.grid_state_to_request(grid_state);
    
    new Ajax.Request(base_path_to_query_controller, {
      asynchronous:true,
      evalScripts:true,
      parameters: request_path + '&query_name=' + encodeURIComponent(query_name)
    })
  },

  grid_state_to_request : function(grid_state){
    return res = grid_state.collect(function(pair){
      return encodeURIComponent(pair[0]) + '=' + encodeURIComponent(pair[1]);
    }).join('&');
  },


  append_to_url : function(url, str){
    if (url.include('?')){
      if (/[&\?]$/.exec(url)){
        sep = '';
      }else{
        sep = '&';
      }
    }else{
      sep = '?';
    }
    return url + sep + str;
  },


  build_url_with_params : function(){
    results = new Array();
    this.filter_declarations.each(function(filter_declaration){
      param = this.read_values_and_form_query_string(
        filter_declaration.filter_name, 
        filter_declaration.detached, 
        filter_declaration.templates, 
        filter_declaration.ids);
      if (param && ! param.empty()){
        results.push(param);
      }
    }.bind(this));
    res = this.base_request_for_filter;
    if ( results.size() != 0){
      all_filter_params = results.join('&');
      res = this.append_to_url(res, all_filter_params);
    }
    return res;
  },



  reset : function(){
    window.location = this.base_request_for_filter;
  },

  export_to_csv : function(){
    window.location = this.link_for_export;
  },


  register : function(func){
    this.filter_declarations.push(func);
  },

  read_values_and_form_query_string : function(filter_name, detached, templates, ids){
    res = new Array();
    for(i = 0; i < templates.length; i++){
      if($(ids[i]) == null){
        if (this.environment == "development"){
          message = 'WiceGrid: Error reading state of filter "' + filter_name + '". No DOM element with id "' + ids[i] + '" found.'
          if (detached){
            message += 'You have declared "' + filter_name + 
              '" as a detached filter but have not output it anywhere in the template. Read documentation about detached filters.'
          }
          alert(message);
        }
        return '';
      }
      val = $F(ids[i]);
      if (val instanceof Array) {
        for(j = 0; j < val.length; j++){
          if (val[j] && ! val[j].empty())
            res.push(templates[i] + encodeURIComponent(val[j]));
        }
      } else if (val && ! val.empty()){
        res.push(templates[i]  + encodeURIComponent(val));
      }
    }
    return res.join('&');
  }

});

function toggle_multi_select(select_id, link_obj, expand_label, collapse_label) {
  select = $(select_id);
  if (select.multiple == true) {
    select.multiple = false;
    link_obj.title = expand_label;
  } else {
    select.multiple = true;
    link_obj.title = collapse_label;
  }
}

WiceGridProcessor._version = '0.4.1';
