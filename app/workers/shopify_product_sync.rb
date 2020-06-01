class ShopifyProductSync
  include Sidekiq::Worker

  def perform(vendor_id)
  	shopify_product_sync = ShopifySync::Base.new(vendor_id)
  	shopify_product_ids = shopify_product_sync.shopify_products.map(&:id)

  	shopify_product_ids.each_with_index do |shopify_product_id, i|
  		ShopifyProductImport.perform_async(vendor_id, shopify_product_id)
  	end

  	ProductRemoval.perform_async(vendor_id, shopify_product_ids)
  	shopify_product_sync.clear_session
  end
end