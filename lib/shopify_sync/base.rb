require 'shopify_api'
require 'open-uri'

class ShopifySync::Base
	def initialize(vendor_id)
		@vendor_id = vendor_id
    ShopifyAPI::Base.activate_session(session)
	end

	def session
		ShopifyAPI::Session.new(
    	domain: vendor.shopify_shop, 
    	token: vendor.shopify_api_token, 
    	api_version: ENV['SHOPIFY_API_VERSION'], 
    	extra: {}
    )
	end

	def clear_session
		ShopifyAPI::Base.clear_session
	end

	def vendor
		Spree::Vendor.find_by(id: @vendor_id)
	end

	def shopify_products
		ShopifyAPI::Product.find(:all)
	end
end