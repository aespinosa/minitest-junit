# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'minitest/junit/version'

Gem::Specification.new do |spec|
  spec.name          = 'minitest-junit'
  spec.version       = Minitest::Junit::VERSION
  spec.authors       = ['Allan Espinosa']
  spec.email         = ['allan.espinosa@outlook.com']
  spec.summary       = 'Junit reporter for Minitest ~> 5.0'
  spec.description   = 'Junit reporter for Minitest ~> 5.0'
  spec.homepage      = 'http://github.com/aespinosa/minitest-junit'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(/^bin\//) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^(test)\//)
  spec.require_paths = ['lib']

  spec.add_dependency 'minitest', '~> 5.11'
  spec.add_dependency 'builder', '~> 3.2'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'nokogiri'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop', '~> 1'
end
