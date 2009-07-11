namespace "wice_grid" do
  
  desc "Copy configuration file to config/initializers"
  task :copy_config_to_initializers   do
    puts "copying wice_grid_config.rb to config/initializers"
    destination = File.join(RAILS_ROOT,  '/config/initializers/wice_grid_config.rb')
    if File.exist?(destination)
      puts "Found wice_grid_config.rb in config/initializers (older version?), thus not copying wice_grid_config.rb...\n" +
           'Please update manually if needed.'
    else
      FileUtils.copy(File.join(RAILS_ROOT,  '/vendor/plugins/wice_grid/assets/wice_grid_config.rb'), destination  )
    end
  end
  
  desc "Copy images, the javascript file, and the stylesheet file to public"
  task :copy_resources_to_public => [:copy_calendar_to_public, :copy_config_to_initializers] do
    puts "copying wice_grid.js to /public/javascripts/"
    FileUtils.copy(
      File.join(RAILS_ROOT,  '/vendor/plugins/wice_grid/javascripts/wice_grid.js'), 
      File.join(RAILS_ROOT,  '/public/javascripts/')
    )
    puts "copying wice_grid.css to /public/stylesheets/"    
    FileUtils.copy(
      File.join(RAILS_ROOT,  '/vendor/plugins/wice_grid/stylesheets/wice_grid.css'), 
      File.join(RAILS_ROOT,  '/public/stylesheets/')
    )

    FileUtils.mkdir_p(File.join(RAILS_ROOT,  "/public/images/icons/grid"))
    images_dir = File.join(RAILS_ROOT,  '/vendor/plugins/wice_grid/images')
    Dir.glob(images_dir + '/*').each do |file|
      puts "copying #{file.split(/\//)[-1]}\tto /public/images/icons/grid"   
      FileUtils.copy(file, File.join(RAILS_ROOT,  '/public/images/icons/grid'))
    end
  end
  
  def copy_set_of_files(src, target, exclusions = [])
    FileUtils.mkdir_p(File.join(RAILS_ROOT,  target))
    src = File.join(RAILS_ROOT,  src)
    Dir.glob(src + '/*').reject{|f| 
      exclusions.index(f.split(/\//)[-1])
    }.each do |file|
      FileUtils.copy(file, File.join(RAILS_ROOT,  target))
    end
    
  end
  
  desc "Copy the DynArch javascript calendar to public"
  task :copy_calendar_to_public do
    puts "copying grid_calendar to /public/javascripts/"
    copy_set_of_files('/vendor/plugins/wice_grid/javascripts/grid_calendar',            '/public/javascripts/grid_calendar', ['lang', 'skins'])
    copy_set_of_files('/vendor/plugins/wice_grid/javascripts/grid_calendar/lang',       '/public/javascripts/grid_calendar/lang')
    copy_set_of_files('/vendor/plugins/wice_grid/javascripts/grid_calendar/skins',      '/public/javascripts/grid_calendar/skins', ['aqua'])
    copy_set_of_files('/vendor/plugins/wice_grid/javascripts/grid_calendar/skins/aqua', '/public/javascripts/grid_calendar/skins/aqua')
  end  
  

  desc "Create a table to store saved queries"
  task :create_queries_table => :environment do
    
    class CreateWiceGridSerializedQueriesTable < ::ActiveRecord::Migration
      def self.up
        create_table :wice_grid_serialized_queries do |t|
          t.column :name,      :string
          t.column :grid_name, :string
          t.column :query,     :text
          t.column :grid_hash, :string

          t.timestamps
        end
        add_index :wice_grid_serialized_queries, :grid_name
        add_index :wice_grid_serialized_queries, [:grid_name, :id]
      end

      def self.down
        drop_table :wice_grid_serialized_queries
      end
    end
    
    CreateWiceGridSerializedQueriesTable.up
  end
  
  
end