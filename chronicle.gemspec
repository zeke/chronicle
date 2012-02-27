# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "chronicle/version"

Gem::Specification.new do |s|
  s.name        = "chronicle"
  s.version     = Chronicle::VERSION
  s.authors     = ["Zeke Sikelianos"]
  s.email       = ["zeke@sikelianos.com"]
  s.homepage    = "http://zeke.sikelianos.com"
  s.summary     = %q{Chronicle groups collections of ActiveRecord objects into chronologically ordered hashes.}
  s.description = %q{Chronicle groups collections of ActiveRecord objects into chronologically ordered hashes.}

  s.rubyforge_project = "chronicle"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "hoe"
  s.add_development_dependency 'rspec', '~> 2.8.0'
  s.add_development_dependency 'autotest'

  s.add_runtime_dependency "chronic"
  s.add_dependency 'rails'
end
