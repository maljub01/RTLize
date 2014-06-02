$:.push File.expand_path("../lib", __FILE__)
require "rtlize/version"

Gem::Specification.new do |s|
  s.name        = "rtlize"
  s.summary     = "Automatic CSS layout switcher (from LTR to RTL)"
  s.version     = Rtlize::VERSION
  s.authors     = ["Marwan Al Jubeh"]
  s.email       = ["marwan.al.jubeh@gmail.com"]
  s.homepage    = "http://github.com/maljub01/RTLize"

  s.files       = Dir["{app,config,db,lib,test}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files  = Dir["test/**/*"]
  s.license     = "MIT"

  s.add_development_dependency "rails", ">= 3.1.0"
  s.add_development_dependency "sass-rails"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "simplecov"

  s.description = <<-END
RTLize allows you to write your stylesheets for left-to-right (LTR) layouts
and have them automatically work for right-to-left (RTL) layouts as well.
END

end
