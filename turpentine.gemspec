$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "turpentine/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "turpentine"
  s.version     = Turpentine::VERSION
  s.authors     = ["Ian Turgeon"]
  s.email       = ["iturgeon@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Turpentine."
  s.description = "TODO: Description of Turpentine."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.1.6", ">= 5.1.6.1"
end
