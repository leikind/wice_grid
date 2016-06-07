module WiceGrid #:nodoc:
  module Generators #:nodoc:
    class InstallGenerator < Rails::Generators::Base #:nodoc:
      desc 'Copy WiceGrid wice_grid_config.rb to config/initializers'

      source_root File.expand_path('../templates', __FILE__)

      def copy_stuff #:nodoc:
        template 'wice_grid_config.rb', 'config/initializers/wice_grid_config.rb'
      end
    end
  end
end
