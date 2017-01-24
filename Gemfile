source "http://rubygems.org"

# Declare your gem's dependencies in rtlize.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

rails_version = ENV["RAILS_VERSION"] || "4.2.2"

rails = case rails_version
when "master"
  {:github => "rails/rails"}
else
  "~> #{rails_version}"
end

gem "rails", "4.2.2"
gem 'sass-rails', '~> 5.0.1'
gem 'uglifier', '>= 1.3.0'
gem 'sprockets', '3.2'
gem 'sprockets-rails', '2.3.1'
gem 'byebug'
