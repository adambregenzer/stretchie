# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'stretchie/version'

Gem::Specification.new do |spec|
  spec.name          = 'stretchie'
  spec.version       = Stretchie::VERSION
  spec.authors       = ['Adam Bregenzer']
  spec.email         = ['adam@bregenzer.net']
  spec.summary       = 'An ActiveModel concern for integrating ElasticSearch.'
  spec.description   = 'Comfortable searching pants for ActiveRecord Models. Stretchie simplifies using elastic search in your models and provides hooks to ease testing.'
  spec.homepage      = 'https://github.com/adambregenzer/stretchie'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'rails', '~> 4.1', '>= 4.1.1'
  spec.add_dependency 'elasticsearch-model', '~> 0.1', '>= 0.1.4'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake', '~> 10.3', '>= 10.3.2'
  spec.add_development_dependency 'rspec', '~> 3.0', '>= 3.0.0'
  spec.add_development_dependency 'simplecov', '~> 0.8', '>= 0.8.2'
  spec.add_development_dependency 'sqlite3', '~> 1.3', '>= 1.3.9'
end
