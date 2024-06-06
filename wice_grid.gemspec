Gem::Specification.new do |s|
  s.name          = 'wice_grid'
  s.version       = '7.1.0'
  s.authors       = ['Yuri Leikind and contributors']
  s.email         = ['koulikoff@gmail.com']
  s.homepage      = 'https://github.com/leikind/wice_grid'
  s.summary       = 'A Rails grid plugin to quickly create grids with sorting, pagination, and filters.'
  s.description   = 'A Rails grid plugin to create grids with sorting, pagination, and filters generated automatically based on column types. ' \
    'The contents of the cell are up for the developer, just like one does when rendering a collection via a simple table. ' \
    'WiceGrid automates implementation of filters, ordering, paginations, CSV export, and so on. ' \
    'Ruby blocks provide an elegant means for this.'

  s.files         = `git ls-files`.split $INPUT_RECORD_SEPARATOR
  s.license       = 'MIT'
  s.require_paths = ['lib']
  s.date          = `date +%Y-%m-%d`

  s.add_dependency 'rails', '~> 7.1.3'
  s.add_dependency 'kaminari'
  s.add_dependency 'coffee-rails'

  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'byebug'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'capybara-screenshot'
  s.add_development_dependency 'faker'
  s.add_development_dependency 'phantomjs', '>= 2.1.1'
  s.add_development_dependency 'poltergeist'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'shoulda-matchers'

  # Required by the test app.
  s.add_development_dependency 'bootstrap-sass', '3.1.1.1'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'coderay'
  s.add_development_dependency 'font-awesome-sass', '4.4.0'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'haml'
  s.add_development_dependency 'inch'
  s.add_development_dependency 'jquery-rails'
  s.add_development_dependency 'jquery-ui-rails'
  s.add_development_dependency 'jquery-ui-themes'
  s.add_development_dependency 'rdoc'
  s.add_development_dependency 'sass-rails', '>= 3.2'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'stimulus-rails'
  s.add_development_dependency 'sqlite3', '~> 1.4'
  s.add_development_dependency 'therubyracer'
  s.add_development_dependency 'turbolinks'
  s.add_development_dependency 'yard'
end
