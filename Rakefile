require "bundler/gem_tasks"
require 'rdoc/task'

task default: :rdoc

desc 'Generate documentation for the wice_grid plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'WiceGrid'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('SAVED_QUERIES_HOWTO.rdoc')
  rdoc.rdoc_files.include('CHANGELOG')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
