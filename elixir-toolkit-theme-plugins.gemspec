# coding: utf-8
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'elixir-toolkit-theme-plugins/version'
require 'rake'

Gem::Specification.new do |spec|
  spec.name          = "elixir-toolkit-theme-plugins"
  spec.version       =  Jekyll::Ett::VERSION.dup
  spec.authors       = ["bedroesb", "janslifka", "MarekSuchanek"]
  spec.email         = ["bert.droesbeke@vib.be\n"]

  spec.summary       = "Plugins to work together with ELIXIR Toolkit theme"
  spec.homepage      = "https://elixir-belgium.github.io/elixir-toolkit-theme-plugins/"
  spec.license       = "MIT"

  spec.date        = Time.now

  spec.files         = `git ls-files -z`.split("\x0")
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "jekyll", '~> 4.3', ">= 4.3.1"
  spec.add_development_dependency "rake", "~> 12.0"
end
