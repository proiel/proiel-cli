# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'proiel/cli/version'

Gem::Specification.new do |spec|
  spec.name          = "proiel-cli"
  spec.version       = PROIEL::CLI::VERSION
  spec.authors       = ["Marius L. Jøhndal", "Dag Haug"]
  spec.email         = ["mariuslj@ifi.uio.no"]
  spec.summary       = %q{A command-line interface for working with PROIEL treebanks}
  spec.description   = %q{This provides a command-line interface to various tools that manipulate treebanks that use the PROIEL dependency format.}
  spec.homepage      = "http://proiel.github.com"
  spec.license       = "MIT"

  spec.files         = Dir["{bin,contrib,lib}/**/*"] + %w(README.md LICENSE)
  spec.executables   = %w(proiel)
  spec.require_paths = ["lib"]

  spec.add_dependency 'builder', '~> 3.2.2'
  spec.add_dependency 'mercenary', '~> 0.3.5'
  spec.add_dependency 'colorize', '~> 0.7'
  spec.add_dependency 'proiel', '~> 1.2'
  spec.add_dependency 'ruby-progressbar', '~> 1.8'
  spec.add_dependency 'pry', '~> 0.10'

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rspec', '~> 3.6'
  spec.add_development_dependency 'simplecov', '~> 0.14'
  spec.add_development_dependency 'cucumber', '~> 2.4'
  spec.add_development_dependency 'aruba', '~> 0.14'
  spec.add_development_dependency 'yard', '~> 0.9'
end
