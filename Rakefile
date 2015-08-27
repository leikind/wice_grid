# encoding: utf-8
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

require 'yard'
require 'yard/rake/yardoc_task'
desc 'Generate documentation for the wice_grid plugin.'
YARD::Rake::YardocTask.new(:rdoc) do |t|
  OTHER_PATHS = %w()

  t.files   = ['lib/**/*.rb', OTHER_PATHS]
  t.options = %w(--main=README.md --file TODO.md,CHANGELOG.md,SAVED_QUERIES_HOWTO.md,MIT-LICENSE)
  t.stats_options = ['--list-undoc']
end

desc 'Run RSpec with code coverage'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['spec'].execute
end

task default: [:rubocop, :spec, :rdoc]
