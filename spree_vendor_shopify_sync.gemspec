# encoding: UTF-8
lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'spree_vendor_shopify_sync/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_vendor_shopify_sync'
  s.version     = SpreeVendorShopifySync.version
  s.summary     = "Allow Spree Marketplace Vendors to sync their Spree Stores with their Shopify Stores."
  s.description = "Allow Spree Marketplace Vendors to sync their Spree Stores with their Shopify Stores."
  s.required_ruby_version = '>= 2.2.7'

  s.author    = 'Ashley Van De Poel'
  s.email     = 'ashley@kindbuys.com'
  s.homepage  = 'https://github.com/kindbuys/spree_vendor_shopify_sync'
  s.license = 'BSD-3-Clause'

  s.files       = `git ls-files`.split("\n").reject { |f| f.match(/^spec/) && !f.match(/^spec\/fixtures/) }
  s.require_path = 'lib'
  s.requirements << 'none'

  spree_version = '>= 3.2.0', '< 5.0'
  s.add_dependency 'spree_core', spree_version
  s.add_dependency 'spree_backend', spree_version
  s.add_dependency 'spree_extension'

  s.add_dependency 'deface'
  s.add_dependency 'sidekiq'
  s.add_dependency 'shopify_api'
  s.add_dependency 'sidekiq-throttled'
  s.add_dependency 'shopify_app'

  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'awesome_print'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'capybara-screenshot'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_bot', '~> 4.7'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'mysql2'
  s.add_development_dependency 'pg'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rspec-rails', '~> 4.0.0.beta2'
  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'webdrivers', '~> 4.0.0'
end
