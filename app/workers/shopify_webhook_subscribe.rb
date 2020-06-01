require 'shopify_api'

class ShopifyWebhookSubscribe
	include Sidekiq::Worker

	def perform(vendor_id)
		vendor = Spree::Vendor.find(vendor_id)
		puts "SUBSCRIBING TO WEBHOOKS"
		ShopifyAPI::Session.temp(domain: vendor.shopify_domain, token: vendor.shopify_token, api_version: ENV['SHOPIFY_API_VERSION']) do
	    puts KINDBUYS_URL
	    ShopifyAPI::Webhook.create( :topic => 'products/create', :format  => 'json', :address => "#{KINDBUYS_URL}/admin/shopify_sync/sync_product")
	  	ShopifyAPI::Webhook.create( :topic => 'products/update', :format  => 'json', :address => "#{KINDBUYS_URL}/admin/shopify_sync/sync_product")
	  	ShopifyAPI::Webhook.create( :topic => 'products/delete', :format  => 'json', :address => "#{KINDBUYS_URL}/admin/shopify_sync/delete_product")
	  end
	end
end
