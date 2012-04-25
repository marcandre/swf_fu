$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "swf_fu/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "swf_fu"
  s.version     = SwfFu::VERSION
  s.authors     = ["Marc-André Lafortune"]
  s.email       = ["github@marc-andre.ca"]
  s.homepage    = "http://github.com/marcandre/swf_fu"
  s.summary     = "Rails.supported_asset_types << 'swf'"
  s.description = "Treat your swf files like other assets"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 3.1"
  s.add_dependency "coffee-script"


  s.add_development_dependency "shoulda-context"
  s.add_development_dependency "sqlite3"
end
