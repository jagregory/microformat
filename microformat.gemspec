# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'microformat/version'

Gem::Specification.new do |spec|
  spec.name          = 'otg-microformat'
  spec.version       = Microformat::VERSION
  spec.authors       = ['On the Game, James Gregory']
  spec.email         = ['james@onthegame.com.au']
  spec.description   = 'A basic microformat parser for Ruby.'
  spec.summary       = 'Simple Microformat parser'
  spec.homepage      = 'http://www.onthegame.com.au/about/opensource'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'nokogiri'
  spec.add_dependency 'andand'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
