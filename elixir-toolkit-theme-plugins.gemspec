# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "elixir-toolkit-theme-plugins"
  spec.version       = "0.1.1"
  spec.authors       = ["bedroesb","janslifka"]
  spec.email         = ["bedro@psb.vib-ugent.be\n"]

  spec.summary       = "Plugins to work together with ELIXIR Toolkit theme"
  spec.homepage      = "https://elixir-belgium.github.io/elixir-toolkit-theme-plugins/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "jekyll", "~> 3.9"

  spec.add_development_dependency "bundler", ">= 2.2.16"
  spec.add_development_dependency "rake", "~> 12.0"
end
