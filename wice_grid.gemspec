Gem::Specification.new do |s|
  s.name = "wice_grid"
  s.version = "3.5.0pre1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors       = ["Yuri Leikind"]
  s.date          = "2015-03-01"
  s.summary       = "A Rails grid plugin to quickly create grids with sorting, pagination, and filters."
  s.description   = "A Rails grid plugin to create grids with sorting, pagination, and filters generated automatically based on column types. " +
                    "The contents of the cell are up for the developer, just like one does when rendering a collection via a simple table. "    +
                    "WiceGrid automates implementation of filters, ordering, paginations, CSV export, and so on. "                              +
                    "Ruby blocks provide an elegant means for this."
  s.email            = "yuri.leikind@gmail.com"
  s.files            = `git ls-files`.split($/)
  s.homepage         = "https://github.com/leikind/wice_grid"
  s.license          = "MIT"
  s.rubygems_version = "2.2.2"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<kaminari>, [">= 0.13.0"])
      s.add_runtime_dependency(%q<coffee-rails>, [">= 0"])
    else
      s.add_dependency(%q<kaminari>, [">= 0.13.0"])
      s.add_dependency(%q<coffee-rails>, [">= 0"])
    end
  else
    s.add_dependency(%q<kaminari>, [">= 0.13.0"])
    s.add_dependency(%q<coffee-rails>, [">= 0"])
  end

end
