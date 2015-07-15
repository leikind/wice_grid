# encoding: utf-8
module WiceGrid #:nodoc:
  module Generators #:nodoc:
    class AddMigrationForSerializedQueriesGenerator < Rails::Generators::Base  #:nodoc:
      include Rails::Generators::Migration

      desc 'Add a migration which creates a table for serialized queries'

      source_root File.expand_path('../templates', __FILE__)

      def self.next_migration_number(_path)
        Time.now.utc.strftime('%Y%m%d%H%M%S')
      end

      def create_model_file
        migration_template 'create_wice_grid_serialized_queries.rb', 'db/migrate/create_wice_grid_serialized_queries.rb'
      end
    end
  end
end
