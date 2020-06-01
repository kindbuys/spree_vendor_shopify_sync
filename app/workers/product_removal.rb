class ProductRemoval
  include Sidekiq::Worker

  def perform(vendor_id, shopify_product_ids)
  	sync = ShopifySync::Base.new(vendor_id)

  	shopify_product_sync = ShopifySync::Import::Products.new(vendor_id)
    shopify_product_sync.remove_old_products(shopify_product_ids)
    
    sync.clear_session
  end
end