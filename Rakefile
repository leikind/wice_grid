require 'bundler/gem_tasks'
require 'rdoc/task'
require 'yard'
require 'yard/rake/yardoc_task'

task default: :doc

desc 'Generate documentation for the wice_grid plugin.'
YARD::Rake::YardocTask.new(:doc) do |t|
  OTHER_PATHS = %w()

  t.files   = ['lib/**/*.rb', OTHER_PATHS]
  t.options = %w(--main=README.md --file CHANGELOG.md,SAVED_QUERIES_HOWTO.md,MIT-LICENSE)
  t.stats_options = ['--list-undoc']
end
