Gem::Specification.new do |s|
  s.name          = 'wice_grid'
  s.version       = '3.4.1'
  s.homepage      = 'https://github.com/leikind/wice_grid'
  s.date          = '2013-10-17'
  s.summary       = 'A Rails grid plugin to create grids with sorting, pagination, and (automatically generated) filters.'
  s.description   = 'A Rails grid plugin to create grids with sorting, pagination, and (automatically generated) filters.' +
                    'One of the goals of this plugin was to allow the programmer to define the contents of the cell by himself, '  +
                    'just like one does when rendering a collection via a simple table (and this is what differentiates WiceGrid ' +
                    'from various scaffolding solutions), but automate implementation of filters, ordering, paginations, CSV '     +
                    'export, and so on. Ruby blocks provide an elegant means for this.'
  s.authors       = ['Yuri Leikind']
  s.email         = 'yuri.leikind@gmail.com'
  s.files         = `git ls-files`.split($/)
  s.license    = 'MIT'

  kaminary         = 'kaminari'
  kaminary_version = '>= 0.13.0'

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(kaminary, [kaminary_version])
    else
      s.add_dependency(kaminari, [kaminary_version])
    end
  else
    s.add_dependency(kaminari, [kaminary_version])
  end

end
