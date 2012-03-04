module WiceGrid #:nodoc:
  module Generators #:nodoc:
    class InstallGenerator < Rails::Generators::Base #:nodoc:

      desc "Copy WiceGrid assets"
      source_root File.expand_path('../templates', __FILE__)

      def copy_stuff #:nodoc:
        template 'wice_grid_config.rb', 'config/initializers/wice_grid_config.rb'

        copy_file 'wice_grid.yml',  'config/locales/wice_grid.yml'

        copy_file 'wice_grid.js',  'app/assets/javascripts/wice_grid.js'
        copy_file 'wice_grid.css',  'app/assets/stylesheets/wice_grid.css'

        %w(arrow_down.gif calendar_view_month.png expand.png page_white_find.png table_refresh.png
          arrow_up.gif delete.png page_white_excel.png  table.png tick_all.png untick_all.png ).each do |f|
            copy_file "icons/#{f}",  "app/assets/images/icons/grid/#{f}"
        end
      end

    end
  end
end
