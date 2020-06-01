
class ShopifyProductImport
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_throttle({
    :concurrency => { :limit => 1, :key_suffix => -> (vendor_id, *) { vendor_id } }
  })


  def perform(vendor_id, shopify_product_id)
  	puts "PERFORMING #{shopify_product_id}"

    sync = ShopifySync::Base.new(vendor_id)
    shopify_product_sync = ShopifySync::Import::Products.new(vendor_id, shopify_product_id)
    shopify_product_sync.sync_product
    sync.clear_session
  end
end