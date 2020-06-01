class ShopifyWebhookSubscribe
	include Sidekiq::Worker

	def perform(vendor_id)
		vendor = Spree::Vendor.find(vendor_id)
		ShopifyAPI::Session.temp(domain: vendor.shopify_shop, token: vendor.shopify_api_token, api_version: ENV['SHOPIFY_API_VERSION']) do
	    ShopifyAPI::Webhook.create( :topic => 'products/create', :format  => 'json', :address => "#{KINDBUYS_URL}/admin/shopify_sync/sync_product")
	  	ShopifyAPI::Webhook.create( :topic => 'products/update', :format  => 'json', :address => "#{KINDBUYS_URL}/admin/shopify_sync/sync_product")
	  	ShopifyAPI::Webhook.create( :topic => 'products/delete', :format  => 'json', :address => "#{KINDBUYS_URL}/admin/shopify_sync/delete_product")
	  end
	end
end