require 'rbconfig'
HOST_OS = RbConfig::CONFIG['host_os']
source 'http://rubygems.org'
gem 'rails', '3.2.2'
gem 'mysql2'
group :assets do
	gem 'sass-rails',   '~> 3.2.3'
	gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
	gem "twitter-bootstrap-rails"
	gem "client_side_validations"
end
gem 'jquery-rails'
if HOST_OS =~ /linux/i
  gem 'therubyracer', '>= 0.9.8'
end
gem "rspec-rails", ">= 2.8.0.rc1", :group => [:development, :test]

group :test do
	gem "factory_girl_rails", ">= 1.4.0"
	gem "cucumber-rails", ">= 1.2.0"
	gem "capybara", ">= 1.1.2"
	gem "database_cleaner", ">= 0.7.0"
	gem "launchy", ">= 2.0.5"
	gem "mocha"
end

group :development do
	gem "guard", ">= 0.6.2"
	gem "guard-bundler", ">= 0.1.3"
	gem "guard-rails", ">= 0.0.3"
	gem "guard-livereload", ">= 0.3.0"
	gem "guard-rspec", ">= 0.4.3"
	gem "guard-cucumber", ">= 0.6.1"
	gem "rails-footnotes", ">= 3.7"
	gem "nifty-generators"
	gem "letter_opener"
end

gem "devise", ">= 1.5.0"
gem "has_scope"
gem "simple_form"
gem "nested_form", :git => 'git://github.com/ryanb/nested_form.git'
gem "cancan", :git => "git://github.com/ryanb/cancan.git", :branch => "2.0"
gem "paperclip", '2.7.0'
gem "delayed_job_active_record"
gem "will_paginate", "~> 3.0"
gem "squeel"
gem "tire"
# gem 'elastic_searchable'
# gem 'rd_searchlogic', :require => 'searchlogic', :git => 'git://github.com/railsdog/searchlogic.git'
gem "ransack"#, :git => "git://github.com/ernie/ransack.git"
gem "has_scope"
gem "ancestry"
gem "private_pub"
gem "thin"
gem "capistrano"
