class WiceGridAssetsPrototypeGenerator < Rails::Generator::Base
  def active_js_framework
    'prototype'
  end
  def inactive_js_framework
    'jquery'
  end

  def manifest
    record do |m|
      # wice_grid config
      m.directory "config/initializers"
      m.template "../../common_templates/initializers/wice_grid_config.rb",  "config/initializers/wice_grid_config.rb"

      # wice_grid locales
      m.directory "config/locales"
      m.file "../../common_templates/locales/wice_grid.yml",  "config/locales/wice_grid.yml"

      # wice_grid js & css
      m.file "javascripts/wice_grid_prototype.js",  "public/javascripts/wice_grid.js"
      m.file "../../common_templates/stylesheets/wice_grid.css",  "public/stylesheets/wice_grid.css"

      # calendarview js & css
      m.file "javascripts/calendarview.js",  "public/javascripts/calendarview.js"
      m.file "stylesheets/calendarview.css",  "public/stylesheets/calendarview.css"

      # images
      m.directory "public/images/icons/grid"
      
      %w(arrow_down.gif calendar_view_month.png expand.png page_white_find.png table_refresh.png  
        arrow_up.gif delete.png page_white_excel.png  table.png tick_all.png untick_all.png ).each do |f|
          m.file "../../common_templates/icons/#{f}",  "public/images/icons/grid/#{f}"
      end
      
    end
  end
end
