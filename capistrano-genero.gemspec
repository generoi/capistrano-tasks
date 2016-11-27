# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = 'capistrano-genero'
  gem.version       = '1.0.0'
  gem.authors       = ['Oskar Schöldström']
  gem.email         = ['public@oxy.fi']
  gem.description   = <<-EOF.gsub(/^\s+/, '')
    Genero Capistrano tasks

    Works *only* with Capistrano 3+.
  EOF
  gem.summary       = 'Genero Capistrano tasks'
  gem.homepage      = 'https://github.com/generoi/capistrano-tasks'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'capistrano', '>= 3.1'

  gem.add_development_dependency 'rake'
end
