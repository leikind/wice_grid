Gem::Specification.new do |s|
  s.name          = 'wice_grid'
  s.version       = '6.1.0'
  s.authors       = ['Yuri Leikind and contributors']
  s.email         = ['koulikoff@gmail.com']
  s.homepage      = 'https://github.com/patricklindsay/wice_grid'
  s.summary       = 'A Rails grid plugin to quickly create grids with sorting, pagination, and filters.'
  s.description   = 'A Rails grid plugin to create grids with sorting, pagination, and filters generated automatically based on column types. ' \
    'The contents of the cell are up for the developer, just like one does when rendering a collection via a simple table. ' \
    'WiceGrid automates implementation of filters, ordering, paginations, CSV export, and so on. ' \
    'Ruby blocks provide an elegant means for this.'

  s.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.license       = 'MIT'
  s.require_paths = ['lib']
  s.date          = '2024-06-07'

  s.add_dependency 'rails', '>= 5.0'
  s.add_dependency 'kaminari',          ['~> 1.1']
  s.add_dependency 'coffee-rails',      ['> 3.2']
  s.add_dependency 'font-awesome-sass'

  s.add_development_dependency('rake',  '~> 10.1')
  s.add_development_dependency('byebug')
  s.add_development_dependency('appraisal')

  s.add_development_dependency('rspec', '~> 3.6.0')
  s.add_development_dependency('rspec-rails', '~> 3.6.0')
  s.add_development_dependency('shoulda-matchers', '2.8.0')
  s.add_development_dependency('capybara', '~> 3.13.2')
  s.add_development_dependency('faker', '~> 1.8.7')
  s.add_development_dependency('poltergeist', '~> 1.18.0')
  s.add_development_dependency('capybara-screenshot', '~> 1.0.11')
  s.add_development_dependency('selenium-webdriver', '~> 2.51.0')
  s.add_development_dependency('phantomjs', '>= 2.1.1')

  # Required by the test app.
  s.add_development_dependency('haml', '~> 5.0.4')
  s.add_development_dependency('coderay', '~> 1.1.0')
  s.add_development_dependency('jquery-rails', '~> 4.3.3')
  s.add_development_dependency('jquery-ui-rails', '~> 7.0.0')
  s.add_development_dependency('jquery-ui-themes', '~> 0.0.11')
  s.add_development_dependency('sass-rails', '>= 3.2')
  s.add_development_dependency('bootstrap-sass', '3.1.1.1')
  s.add_development_dependency('font-awesome-sass', '4.4.0')
  s.add_development_dependency('turbolinks', '~> 5.1.1')
  s.add_development_dependency('therubyracer')

  s.add_development_dependency('bundler',   '~> 1.3')
  s.add_development_dependency('simplecov', '~> 0.7')
  s.add_development_dependency('sqlite3',   '~> 1.3')

  s.add_development_dependency('yard', '~> 0.8')
  s.add_development_dependency('inch', '~> 0.6.4')
  s.add_development_dependency('rdoc', '~> 4.2.0')
end
