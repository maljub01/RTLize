$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rtlize/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rtlize"
  s.version     = Rtlize::VERSION
  s.authors     = ["Marwan Al Jubeh"]
  s.email       = ["marwan.al.jubeh@gmail.com"]
  s.homepage    = "http://github.com/maljub01/RTLize"
  s.summary     = "Automatic CSS layout switcher (from LTR to RTL) for Rails"
  s.description = "RTLize is a rails plugin that semi-automatically allows you to use the same stylesheet file(s) to produce both left-to-right and right-to-left layouts for your markup. It does this by intelligently switching all the left/right properties and values in the stylesheets you choose to RTLize."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.8"

  s.add_development_dependency "sqlite3"
end
