require 'bundler/gem_tasks'
require 'rdoc/task'
require 'yard'
require 'yard/rake/yardoc_task'

task default: :rdoc

desc 'Generate documentation for the wice_grid plugin.'
YARD::Rake::YardocTask.new(:rdoc) do |t|
  OTHER_PATHS = %w()

  t.files   = ['lib/**/*.rb', OTHER_PATHS]
  t.options = %w(--main=README.md --file TODO.md,CHANGELOG.md,SAVED_QUERIES_HOWTO.md,MIT-LICENSE)
  t.stats_options = ['--list-undoc']
end
