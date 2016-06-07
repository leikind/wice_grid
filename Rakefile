require 'rubygems'
require 'bundler'
require 'bundler/gem_tasks'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts 'Run `bundle install` to install missing gems'
  exit e.status_code
end

require 'rake'
require 'rspec/core'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'

desc 'Run RuboCop on the lib directory'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.patterns = ['lib/**/*.rb']
  # don't abort rake on failure
  task.fail_on_error = false
end

desc 'Run RSpec with code coverage'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['spec'].execute
end

# Experimenting with documentation system we will keep both Yardoc and Rdoc for some time, plus Inch

require 'yard'
require 'yard/rake/yardoc_task'
desc 'Generate YARDOC documentation for the plugin'
YARD::Rake::YardocTask.new(:yardoc) do |t|
  OTHER_PATHS = %w()
  t.files   = ['lib/**/*.rb', OTHER_PATHS]
  t.options = %w(--main=README.md --file TODO.md,CHANGELOG.md,SAVED_QUERIES_HOWTO.md,MIT-LICENSE)
  t.stats_options = ['--list-undoc']
end

gem 'rdoc'
require 'rdoc/task'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'WiceGrid'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('SAVED_QUERIES_HOWTO.md')
  rdoc.rdoc_files.include('CHANGELOG.md')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task default: [:rubocop, :spec, :yardoc]
