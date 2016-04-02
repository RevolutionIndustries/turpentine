$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "turpentine/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "turpentine"
  s.version     = Turpentine::VERSION
  s.authors     = ["Ian Turgeon"]
  s.email       = ["iturgeon@gmail.com"]
  s.homepage    = "https://github.com/RevolutionIndustries/turpentine"
  s.summary     = "Ruby on Rails tools for Varnish."
  s.description = "Ruby on Rails tools for Varnish.  Build edge side includes with partials and clear Varnish cash using BAN and PURGE requests."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 4.2.0"

end
